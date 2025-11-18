/**
 * @file
 * @brief TSM file header tells you about who wrote the file
 *
 * A logFormat2 *file* will have as the first element a fixed-length file header
 * containing the following fields:
 *
 * | Signature | Header version | File Writer ID | File Writer Mode | File Writer PHY | Comment                    |
 * | --------- | -------------- | -------------- | ---------------- | --------------- | -------------------------- |
 * | 3 chars   | 1 byte         | 4 bytes        | 1 bytes          | 1 bytes         | 63 chars + NULL            |
 * | TSM       | 0x01           | 0xEC4A5B66     | 0x00             | 0x00            | V6.0.0-43-g33bc925-develop |
 *
 * * Signature - A three character signature, always "TSM"
 *   * This originally stood for tome safety message, but was changed to be "the logged safety message"
 * * Header version - A version *for the file header only*
 * * File Writer ID - The J2735 TemporaryID of the device that is writing the the file
 * * Mode of the writer (sender, receiver, receiver with sensors see tsm_mode_e)
 * * PHY of the writer (see tsm_phy_e)
 * * Comment - A 63 character comment, terminated by a NULL
 */
#ifndef SERIALIZATION_TSM_H
#define SERIALIZATION_TSM_H

#include "serialization-errors.h"
#include "libsm.h"

/** @brief mode of TSM writer */
typedef enum {
    TSM_MODE_SENDER,
    TSM_MODE_RECEIVER,
    TSM_MODE_RECEIVER_WITH_SENSORS,
    TSM_MODE_UNAVAILABLE,
    TSM_MODE_INVALID
} __attribute((packed)) tsm_mode_e;

/** @brief PHY of tsm writer */
typedef enum {
    TSM_PHY_1M,
    TSM_PHY_2M,
    TSM_PHY_CODED,
    TSM_PHY_UNAVAILABLE,
    TSM_PHY_INVALID
} __attribute((packed)) tsm_phy_e;

/** @brief versions of TSM header */
typedef enum { TSM_VERSION_V1 = 1, TSM_VERSION_INVALID } __attribute((packed)) tsm_version_e;


/** @brief Struct for logFormat2 file header */
typedef struct __attribute__((packed)) {
    uint8_t signature[3];  /**< Signature of tsm file. Hardcoded to "TSM" */
    tsm_version_e version; /**< Version of file header */
    uint8_t loggerID[4];   /**< TemporaryID of the file writer */
    tsm_mode_e mode;       /**< mode of file writer */
    tsm_phy_e phy;         /**< PHY of file writer */
    char comment[64];      /**< 63 chars plus NULL */
} serialization_tsm_header_t;

/** @brief give the size of a header as a macro so we can do version stuff */
#define TSM_HEADER_SIZE sizeof(serialization_tsm_header_t)


/**
 * @brief stringify a TSM mode
 *
 * @param  mode value
 * @return      a string describing the enum
 */
const char* serialization_tsm_mode2str(tsm_mode_e mode);


/**
 * @brief stringify a TSM phy
 *
 * @param  phy value
 * @return     a string describing the enum
 */
const char* serialization_tsm_phy2str(tsm_phy_e phy);


/**
 * @brief stringify a TSM version
 *
 * @param  version value
 * @return         a string describing the enum
 */
const char* serialization_tsm_version2str(tsm_version_e version);


/**
 * @brief parse TSM mode string into TSM mode enum
 *
 * @param  type string to parse
 * @return      enum value
 */
tsm_mode_e serialization_tsm_str2mode(const char* type);


/**
 * @brief parse TSM phy string into TSM phy enum
 *
 * @param  phy string to parse
 * @return     enum value
 */
tsm_phy_e serialization_tsm_str2phy(const char* phy);


/**
 * @brief parse TSM version string into TSM version enum
 *
 * @param  version string to parse
 * @return         enum value
 */
tsm_version_e serialization_tsm_str2version(const char* version);


/**
 * @brief Given a serialized_tsm_header struct, serialize into a uint8_t array.
 *        data->comment is less than 64 chars, else fails serialization. The NULL
 *        is inserted automatically.
 *
 * @param[out] out      A buffer to hold the serialized TSM header.
 * @param      out_size The size of the buffer.
 * @param      data     The TSM header struct to serialize.
 *
 * @retval SERIALIZATION_OK                     Operation success.
 * @retval SERIALIZATION_USAGE_BUFFER_TOO_SMALL If the buffer was too small for a serialized TSM header.
 * @retval SERIALIZATION_INPUT_INVALID          If the comment field exceeded 63 chars.
 */
serialization_e serialization_tsm_serialize_header(uint8_t* out,
                                                   size_t* out_size,
                                                   serialization_tsm_header_t* data);


/**
 * @brief Given a logFormat2 TSM V1 serialized TSM header, deserialize into a TSM header struct
 *
 * @param[out] data      The logFormat2 deserialized TSM struct
 * @param      input     The logFormat2 serialized TSM header to process
 * @param      inputSize Size of input
 *
 * @retval SERIALIZATION_OK            Operation success.
 * @retval SERIALIZATION_INPUT_INVALID input is too small to contain a valid header.
 */
serialization_e serialization_tsm_deserialize_header_v1(serialization_tsm_header_t* data,
                                                        uint8_t* input,
                                                        size_t inputSize);


/**
 * @brief Wrapper function to deserialize a TSM header into a TSM header struct
 *
 * @param[out] data      The logFormat2 deserialized TSM struct
 * @param      input     The logFormat2 serialized TSM header to process
 * @param[out] inputSize Size of data (must be larger than a serialization_tsm_header_t)
 *
 * @retval SERIALIZATION_OK                       Operation success.
 * @retval SERIALIZATION_DATA_INVALID_SIZE        If input was too small to contain a valid header, or no signature.
 * @retval SERIALIZATION_DATA_INVALID_UNPARSABLE  If input wasn't a valid TSM header.
 * @retval SERIALIZATION_DATA_INVALID_UNSUPPORTED If input was a TSM header of an unsuppored version.
 *
 */
serialization_e serialization_tsm_deserialize_header(serialization_tsm_header_t* data,
                                                     uint8_t* input,
                                                     size_t inputSize);


#endif // SERIALIZATION_TSM_H
