/**
 * @file
 * @brief Functions for formatting and parsing single types to string
 */
#ifndef SERIALIZATION_FORMATTING_H
#define SERIALIZATION_FORMATTING_H

#include "serialization-errors.h"
#include "libsm.h"


/**
 * @brief TemporaryID_t to FF:FF:FF:FF
 *
 * @param[out]    out      buffer to put string into
 * @param[out]    out_len  size of output string, may be NULL
 * @param         out_size size available in out
 * @param         id       TemporaryID_t to format
 *
 * @retval SERIALIZATION_OK                     Operation success.
 * @retval SERIALIZATION_DATA_EMPTY             If id was NULL.
 * @retval SERIALIZATION_USAGE_BUFFER_TOO_SMALL If out was too small.
 **/
serialization_e serialization_format_TemporaryID(char* out,
                                                 size_t* out_len,
                                                 size_t out_size,
                                                 TemporaryID_t* id);


/**
 * @brief "FF:FF:FF:FF" to TemporaryID_t
 *
 * @param[out] id     TemporaryID struct
 * @param      tempID input string
 *
 * @retval SERIALIZATION_OK                      Operation success.
 * @retval SERIALIZATION_DATA_EMPTY              If string is empty
 * @retval SERIALIZATION_DATA_INVALID_UNPARSABLE can't parse string
 **/
serialization_e serialization_parse_TemporaryID(TemporaryID_t* id, const char* tempID);


/**
 * @brief "FF:FF:FF:FF" to uint8_t[4]
 *
 * @param[out] id     output array
 * @param      tempID input string
 *
 * @retval SERIALIZATION_OK                      Operation success.
 * @retval SERIALIZATION_DATA_EMPTY              If string is empty
 * @retval SERIALIZATION_DATA_INVALID_UNPARSABLE can't parse string
 **/
serialization_e serialization_parse_TemporaryID_arr(uint8_t id[4], const char* tempID);


/**
 * @brief DDateTime_t to (example) 2021-05-21T18:13:40.400Z
 *
 * @param[out]    out      buffer to put string into
 * @param[out]    out_len  size of output string, may be NULL
 * @param         out_size size available in out
 * @param         dt       DDateTime_t to format
 *
 * @retval SERIALIZATION_OK                     Operation success.
 * @retval SERIALIZATION_DATA_EMPTY             If dt was NULL.
 * @retval SERIALIZATION_USAGE_BUFFER_TOO_SMALL If out was too small.
 *
 **/
serialization_e serialization_format_DDateTime(char* out,
                                               size_t* out_len,
                                               size_t out_size,
                                               DDateTime_t* dt);


/**
 * @brief parse 2021-05-21T18:13:40.400Z to DDateTime_t
 *
 * @param[out] dt    DDateTime_t output
 * @param      input string to parse
 *
 * @retval SERIALIZATION_OK                      Operation success.
 * @retval SERIALIZATION_DATA_EMPTY              If input was NULL or empty.
 * @retval SERIALIZATION_DATA_INVALID_UNPARSABLE If input wasn't parsable.
 * @retval SERIALIZATION_DATA_INVALID_RANGE      If input numbers were outside acceptable range.
 *
 **/


serialization_e serialization_parse_DDateTime(DDateTime_t* dt, const char* input);


#endif // SERIALIZATION_FORMATTING_H
