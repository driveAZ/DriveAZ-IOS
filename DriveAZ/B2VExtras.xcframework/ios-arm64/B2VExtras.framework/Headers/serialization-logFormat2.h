/**
 * @file
 * @brief functions for logFormat2
 *
 * It used to be called tome2
 *
 * LOG_FORMAT_2, as described in OSI layers
 * * logFormat2 data  (OSI 7): serialization_logFormat2_data_t, libsm decoded and all that
 * * logFormat2 packet(OSI 3): serialization_logFormat2_data_packet_t, has CRC
 * * logFormat2 frame (OSI 2): an array of bytes that is a cobs-encoded logFormat2 packet with null framing
 *
 * All logFormat2_packet versions *must* have mf_len and mf[] LAST, memory reasons.
 *
 * | CRC16   | Record Version | Channel | RSSI   | optional fields | Message Frame Length | UPER Encoded Message Frame |
 * | ------- | -------------- | ------- | ----   | --------------- | -------------------- | -------------------------- |
 * | 2 bytes | 1 byte         | uint8_t | int8_t | v1 has none     | uint8_t              | (MF len) bytes             |
 * | 0x9F17  | 0x01           | 0x03    | 0xD9   |                 | 0x3A                 | 0x20 ... 0x80              |
 *
 * * CRC16 is the CRC-16/AUG-CCITT of every other field
 * * Record version specifies what fields exist between the RSSI and the message frame length
 *
 * # logFormat2-Version 1
 * This version of logFormat2 contains the basic elements and has no extraFields
 *
 * # logFormat2-Version 2
 * This version of logFormat2 contains everything in logFormat2 version 1, plus extraFields
 * for queue_in and queue_out times.
 */
#ifndef SERIALIZATION_LOG_FORMAT_2_H
#define SERIALIZATION_LOG_FORMAT_2_H

#include "serialization-errors.h"
#include "libsm.h"

/** versions of log format 2 */
typedef enum __attribute__((packed)) {
    LOGFORMAT2_v1 = 1,
    LOGFORMAT2_v2 = 2
} logFormat2_version_e;

/**
 * @defgroup logFormat2_data_packet_structs logformat2 packet structs
 * @{
 */

/** version dependent struct for serialization_logFormat2_data_packet_t */
typedef struct __attribute__((packed)) {
    uint8_t mf_len; /**< length of mf */
    uint8_t mf[];   /**< variable length UPER MessageFrame */
} serialization_logFormat2_data_packet_v1_t;

/**  @copydoc serialization_logFormat2_data_packet_v1_t */
typedef struct __attribute__((packed)) {
    int32_t queue_in;  /**< debug time packet put into queue */
    int32_t queue_out; /**< debug time packet removed from queue */
    uint8_t mf_len;    /**< length of mf */
    uint8_t mf[];      /**< variable length UPER MessageFrame */
} serialization_logFormat2_data_packet_v2_t;

// We can ignore this because we know to treat serialization_logFormat2_data_packet_t.data as a flexible array member.
#ifdef __clang__
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wflexible-array-extensions"
#endif
/**
 * @brief struct to hold logFormat2 packets
 */
typedef struct {
    uint16_t crc;                 /**< crc of the message */
    logFormat2_version_e version; /**< version of tome2 message */
    uint8_t channel;              /**< channel of received advertisement */
    int8_t rssi;                  /**< rssi of received advertisement */
    /** union containing the version specific fields */
    union {
        serialization_logFormat2_data_packet_v1_t v1;
        serialization_logFormat2_data_packet_v2_t v2;
    } data;
} __attribute__((packed)) serialization_logFormat2_data_packet_t;
#ifdef __clang__
#pragma clang diagnostic pop
#endif
/** @} */

/**
 * @defgroup logFormat2_data_structs logformat2 data structs
 * @{
 */

/** version dependent struct for serialization_logFormat2_data_t */
typedef struct {
} serialization_logFormat2_data_v1_t;

/** @copydoc serialization_logFormat2_data_v1_t */
typedef struct {
    int32_t queue_in;  /**< debug time packet put into queue */
    int32_t queue_out; /**< debug time packet removed from queue */
} serialization_logFormat2_data_v2_t;

/**
 * @brief struct to hold logFormat2 data
 * @note mf is a pointer to MessageFrame_t and is freed by ASN_STRUCT_FREE
 */
typedef struct {
    uint8_t channel;              /**< channel of received advertisement */
    int8_t rssi;                  /**< rssi of received advertisement */
    MessageFrame_t* mf;           /**< UPER encoded messageframe */
    logFormat2_version_e version; /**< version of tome2 message */
    /** union containing the version specific fields */
    union {
        serialization_logFormat2_data_v1_t v1;
        serialization_logFormat2_data_v2_t v2;
    } extraFields;
} serialization_logFormat2_data_t;
/** @} */


/**
 * @brief Predicts the size of a logFormat2 packet before it's created.
 *
 * @param  version version of logFormat2 message
 * @param  mf_len  length of the UPER messageframe
 * @return         size of the packet including UPER messageframe, 0 means unsupported version.
 */
size_t serialization_logFormat2_predict_packet_size(logFormat2_version_e version, size_t mf_len);


/**
 * @brief Returns packet size
 *
 * @param  packet serialization_logFormat2_data_packet_t
 * @return        size of the packet including UPER messageframe, 0 means unsupported version.
 */
size_t serialization_logFormat2_packet_size(serialization_logFormat2_data_packet_t* packet);


/**
 * @brief Returns a pointer to the messageframe packet
 *
 * @param  packet serialization_logFormat2_data_packet_t
 * @return        pointer to the UPER messageframe, NULL if unsupported version.
 */
uint8_t* serialization_logFormat2_packet_mf(serialization_logFormat2_data_packet_t* packet);


/**
 * @brief Returns a pointer to the messageframe length
 *
 * @param  packet serialization_logFormat2_data_packet_t
 * @return        pointer to the messageframe length, NULL if unsupported version.
 */
uint8_t* serialization_logFormat2_packet_mf_len_ptr(
        serialization_logFormat2_data_packet_t* packet);


/**
 * @brief Returns length of messageframe
 *
 * @param  packet serialization_logFormat2_data_packet_t
 * @return        length of mf or 0 if unsupported.
 */
uint8_t serialization_logFormat2_packet_mf_len(serialization_logFormat2_data_packet_t* packet);


/**
 * @brief Check packet version
 *
 * @param  version serialization_logFormat2_data_packet_t
 * @return         is version supported
 */
bool serialization_logFormat2_packet_supported(logFormat2_version_e version);


/**
 * @brief Buffer stuff needed to call process functions,
 * Only needs to be big enough to handle a single message at a time
 *
 * @param NAME name to call the buffer
 * @param SIZE must be known at compile time
 */
#define SERIALIZATION_PROCESS_BUF_DEF(NAME, SIZE) \
    uint8_t NAME##_buf[SIZE];                     \
    serialization_logFormat2_process_buf_t NAME = { .buf = NAME##_buf, .cur = 0, .size = SIZE };

/**
 * @brief Static buffer that is needed to call process functions,
 * Only needs to be big enough to handle a single message at a time.
 *
 * @param NAME name to call the buffer
 * @param SIZE must be known at compile time
 */
#define SERIALIZATION_PROCESS_BUF_DEF_STATIC(NAME, SIZE) \
    static uint8_t NAME##_buf[SIZE];                     \
    static serialization_logFormat2_process_buf_t NAME   \
            = { .buf = NAME##_buf, .cur = 0, .size = SIZE };

/**
 * @brief buffer for the serialization_logFormat2_process functions
 *
 * This is intended to be opaque.
 */
typedef struct {
    uint8_t* buf; /**< private */
    size_t cur;   /**< private */
    size_t size;  /**< private */
} serialization_logFormat2_process_buf_t;


/**
 * @brief Function to decode serialization_logFormat2_data_packet_t into serialization_logFormat2_data_t data
 *
 * @note If SERIALIZATION_PROCESS_OK_WITH_DATA is returned, the caller is
 * responsible for setting data->mf to NULL before the next call as well as
 * freeing the memory allocated to data-mf with ASN_STRUCT_FREE
 *
 * @param[out] data   the logFormat2 data (must be allocated and data.mf must be NULL)
 * @param      packet The serialization_logFormat2_data_packet_t to serialization_logFormat2_depacketize
 *
 * @retval SERIALIZATION_OK                       Operation success.
 * @retval SERIALIZATION_USAGE_PARAM_NULL         If data or packet->mf was NULL.
 * @retval SERIALIZATION_DATA_EMPTY               If packet was NULL.
 * @retval SERIALIZATION_USAGE_PARAM_INVALID      If data->mf was NOT NULL.
 * @retval SERIALIZATION_DATA_INVALID_UNSUPPORTED If logFormat2 version wasn't supportd.
 * @retval SERIALIZATION_FAIL_ALLOC               If a memory allocation failed.
 * @retval SERIALIZATION_FAIL_LIBSM               If libsm failed in unhandled way.
 * @retval SERIALIZATION_DATA_INVALID_UNPARSABLE  If we cannot parse messageframe
 */
serialization_e serialization_logFormat2_depacketize(
        serialization_logFormat2_data_t* data,
        serialization_logFormat2_data_packet_t* packet);


/**
 * @brief Deframe a complete logFormat2 frame (byte array) into serialization_logFormat2_data_packet_t.
 *
 * @param[out]    packet     logFormat2 packet struct pointer into frame byte array
 *                           after successful processing, else NULL.
 * @param[in,out] frame      logFormat2 frame to deserialize. After successful processing
 *                           it will hold a serialization_logFormat2_data_packet_t.
 * @param         frame_len  number of bytes to deframe
 *
 * @retval SERIALIZATION_OK                      Operation success.
 * @retval SERIALIZATION_DATA_INVALID_CRC_COBS   COBS failure or length mismatch.
 * @retval SERIALIZATION_USAGE_PARAM_NULL        If frame was null.
 * @retval SERIALIZATION_USAGE_BUFFER_TOO_SMALL  If the output buffer was too small.
 * @retval                                       or any error from @ref serialization_logFormat2_validatePacket.
 **/
serialization_e serialization_logFormat2_deframe(serialization_logFormat2_data_packet_t** packet,
                                                 uint8_t* frame,
                                                 size_t frame_len);


/**
 * @brief deserialize a logFormat2 frame byte array into serialization_logFormat2_data_t data
 *
 * @param[out] data      serialization_logFormat2_data_t data struct with allocated messageframe.
 *                       Must be allocated before calling!
 * @param      frame     logFormat2 frame to deserialize
 * @param      frame_len number of bytes to deserialize
 *
 * @retval SERIALIZATION_OK or any error from @ref serialization_logFormat2_depacketize or @ref serialization_logFormat2_deframe.
 **/
serialization_e serialization_logFormat2_deserialize(serialization_logFormat2_data_t* data,
                                                     uint8_t* frame,
                                                     size_t frame_len);


/**
 * @brief Process up to input_len bytes of input into a packet.
 *        This may or may not be a complete frame.
 *
 * @details If a frame is found, process it into a packet and stop processing input.
 *          If the packet can be processed, serialization_logFormat2_data_packet_t** message will point to it.
 *          If it's just a partial frame, data is added to the buffer and will be
 *          processed whenever we see the end of a frame (marked by a NULL).
 *
 * @param[out]     processed  Number of bytes processed from input.
 * @param[out]     packet     A pointer into buf if we successfully
 *                            deserialized a serialization_logFormat2_data_packet_t packet.
 * @param[in,out]  buf        A buffer used internally to hold the complete (or partial) packet.
 *                            Initialize with SERIALIZATION_PROCESS_BUF_DEF macro.
 * @param          input      Input byte array, it may or may not contain a complete frame
 * @param          input_len  Number of input bytes to process
 *
 * @retval SERIALIZATION_PROCESS_OK_WITH_DATA    Operation success. Complete frame processed.
 * @retval SERIALIZATION_PROCESS_OK_WITHOUT_DATA Operation success. Incomplete frame, more to process.
 * @retval SERIALIZATION_USAGE_BUFFER_TOO_SMALL  If serialization_logFormat2_process_buf_t was too small.
 * @retval SERIALIZATION_DATA_INVALID_UNPARSABLE If input wasn't parsable.
 * @retval                                       or any error from @ref serialization_logFormat2_deframe.
 **/
serialization_e serialization_logFormat2_process_deframe(
        size_t* processed,
        serialization_logFormat2_data_packet_t** packet,
        serialization_logFormat2_process_buf_t* buf,
        uint8_t* input,
        size_t input_len);


/**
 * @brief Convert serialization_logFormat2_data_t data into a serialization_logFormat2_data_packet_t, and insert the packet's CRC
 *
 * @param[out]    packet      The processed packet
 * @param[in,out] packet_len  The packet length, pass NULL if you don't care
 * @param         packet_size The size allotted for the packet
 * @param         data        The serialization_logFormat2_data_t data to process
 *
 * @retval SERIALIZATION_OK                       Operation success.
 * @retval SERIALIZATION_DATA_INVALID_RANGE       If libsm constraint check failed.
 * @retval SERIALIZATION_FAIL_LIBSM               If libsm failed in unhandled way.
 * @retval SERIALIZATION_USAGE_BUFFER_TOO_SMALL   If packet was too small.
 * @retval SERIALIZATION_DATA_INVALID_UNSUPPORTED If logFormat2 version wasn't supportd.
 */
serialization_e serialization_logFormat2_packetize(serialization_logFormat2_data_packet_t* packet,
                                                   size_t* packet_len,
                                                   size_t packet_size,
                                                   serialization_logFormat2_data_t* data);


/**
 * @brief Wrapper function for COBS encoding to convert a packet into a frame.
 *
 * @param[out] frame      The buffer to write frame into.  Pointer must be provided by the caller.
 * @param[out] frame_len  Number of bytes used by frame. Pointer must be provided by the caller.
 * @param      frame_size The size of the frame.
 * @param      packet     The serialization_logFormat2_data_packet_t to serialize into a frame.
 *
 * @retval SERIALIZATION_OK                     Operation success.
 * @retval SERIALIZATION_USAGE_PARAM_NULL       If output or input was null
 * @retval SERIALIZATION_USAGE_BUFFER_TOO_SMALL If output buffer was too small
 * @retval                                      or any error from @ref serialization_logFormat2_validatePacket.
 **/
serialization_e serialization_logFormat2_frame(uint8_t* frame,
                                               size_t* frame_len,
                                               size_t frame_size,
                                               serialization_logFormat2_data_packet_t* packet);


/**
 * @brief All-in-one function to serialize serialization_logFormat2_data_t data into a frame
 *
 * @param[out] frame      the buffer to write frame into
 * @param[out] frame_len  number of bytes used by frame
 * @param      frame_size how big output can be
 * @param      data       the serialization_logFormat2_data_t to serialize into a frame
 * @param      buf        buffer to hold data being processed
 * @param      buf_size   size of buf
 *
 * @retval SERIALIZATION_OK or any error from
 *         @ref serialization_logFormat2_packetize or
 *         @ref serialization_logFormat2_frame.
 */
serialization_e serialization_logFormat2_serialize(uint8_t* frame,
                                                   size_t* frame_len,
                                                   size_t frame_size,
                                                   serialization_logFormat2_data_t* data,
                                                   serialization_logFormat2_data_packet_t* buf,
                                                   size_t buf_size);


/**
 * @brief All-in-one function to deserialize a frame into serialization_logFormat2_data_t data
 *
 * @details If a frame is found, process it into a packet and stop processing input.
 * * If the packet can be processed, serialization_logFormat2_data_t* data will be filled in, and a
 *   MessageFrame_t will be allocated.
 * * If it's just a partial frame, data is added to the buffer and will be
 *   processed whenever we get the end of a frame (marked by a NULL).
 *
 * @note If SERIALIZATION_PROCESS_OK_WITH_DATA is returned, the caller is
 * responsible for setting data->mf to NULL before the next call as well as
 * freeing the memory allocated to data-mf with ASN_STRUCT_FREE.
 *
 * @param[out] processed number of bytes processed processed from input
 * @param[out] data      the serialization_logFormat2_data_t data (data.mf MUST be NULL)
 * @param      buf       buffer to hold data being processed
 * @param      frame     the frame to process
 * @param      frame_len the number of bytes in frame to process
 *
 * @retval SERIALIZATION_OK or any error from @ref serialization_logFormat2_process_deframe or @ref serialization_logFormat2_depacketize.
 */
serialization_e serialization_logFormat2_process(size_t* processed,
                                                 serialization_logFormat2_data_t* data,
                                                 serialization_logFormat2_process_buf_t* buf,
                                                 uint8_t* frame,
                                                 size_t frame_len);


/**
 * @brief check if the packet is a valid and processable packet
 *
 * @param      packet The serialization_logFormat2_data_packet_t to check
 *
 * @retval SERIALIZATION_OK                       Valid packet
 * @retval SERIALIZATION_DATA_INVALID_UNSUPPORTED version not supported
 * @retval SERIALIZATION_USAGE_NO_MESSAGEFRAME    mf_len is 0
 * @retval SERIALIZATION_DATA_INVALID_CRC_COBS    invalid CRC
 */
serialization_e serialization_logFormat2_validatePacket(
        serialization_logFormat2_data_packet_t* packet);


/**
 * @brief Function to calculate and return a CCITT CRC
 *
 * @param     packet The array to calculate the CRC on
 * @return           The 16bit CRC
 */
uint16_t serialization_logFormat2_crc(serialization_logFormat2_data_packet_t* packet);


#endif // SERIALIZATION_LOG_FORMAT_2_H
