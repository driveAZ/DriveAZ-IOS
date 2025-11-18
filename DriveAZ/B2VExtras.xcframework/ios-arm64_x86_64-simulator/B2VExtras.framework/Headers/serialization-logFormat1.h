/**
 * @file
 * @brief Functions for dealing with logFormat1
 *
 * logFormat1 is a human readable logging format that is very space inefficient
 *
 * It used to be called tome1.
 *
 * ```
 * ttt nn xx xx ... xx xx [, rssi[, channel[, debugstring]]]
 * ```
 * * ttt: type, string of **psm** or **bsm**
 * * nn: the length (hex) of the encoded messageframe, including spaces
 * * xx: a hex byte of the variable-length messageframe
 * * rssi: optional int8_t rssi
 * * channel: optional uint8_t channel
 * * debugstring: optional debug string of any length
 */
#ifndef SERIALIZATION_LOG_FORMAT_1_H
#define SERIALIZATION_LOG_FORMAT_1_H

#include "serialization-errors.h"
#include "stddef.h"
#include "stdint.h"

/** types of logFormat1 message */
typedef enum { LOGFORMAT1_PSM, LOGFORMAT1_BSM } logFormat1_message_type_t;

/** logFormat1 message struct */
typedef struct {
    char* input;                    /**< Pointer to the entire input line */
    logFormat1_message_type_t type; /**< Message is either a PSM or BSM */
    uint8_t* uperMF;                /**< pointer to UPER MessageFrame */
    size_t uperMF_len;              /**< length of uperMF */
    int8_t rssi;                    /**< rssi of received advertisement */
    uint8_t channel;                /**< channel of received advertisement */
    char* debugString;              /**< arbitrary string data */
} serialization_logFormat1_data_t;


/**
 * @brief serialize logged safety message as logFormat1
 *
 * Does put a newline in
 *
 * @param[out] out      output buffer for csv data
 * @param[out] out_len  number of chars in output
 * @param      out_size size of output
 * @param      data     data to encode
 *
 * @retval SERIALIZATION_OK                     Operation success.
 * @retval SERIALIZATION_DATA_EMPTY             If data or data->uperMF was NULL.
 * @retval SERIALIZATION_USAGE_BUFFER_TOO_SMALL If out wasn't big enoguh
 **/
serialization_e serialization_logFormat1_serialize(char* out,
                                                   size_t* out_len,
                                                   size_t out_size,
                                                   serialization_logFormat1_data_t* data);


/**
 * @brief deserialize a logFormat1 message
 *
 * @param[out] data   deserialied data
 * @param      input string to parse
 *
 * @retval SERIALIZATION_OK                      Operation success.
 * @retval SERIALIZATION_DATA_INVALID_UNPARSABLE If something couldn't be parsed as a number or date or whatever
 * @retval SERIALIZATION_USAGE_PARAM_NULL        If data->uperMF was NULL.
 * @retval SERIALIZATION_DATA_EMPTY              If input was NULL.
 **/
serialization_e serialization_logFormat1_deserialize(serialization_logFormat1_data_t* data,
                                                     char* input);


#endif // SERIALIZATION_LOG_FORMAT_1_H
