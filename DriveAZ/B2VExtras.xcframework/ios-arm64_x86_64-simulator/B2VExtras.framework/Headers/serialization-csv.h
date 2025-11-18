/**
 * @file serialization-csv.h
 * @brief Handle safety message data in the CSV format
 *
 */
#ifndef SERIALIZATION_CSV_H
#define SERIALIZATION_CSV_H

#include "serialization-errors.h"
#include "libsm.h"

/** @brief container for csv data */
typedef struct {
    MessageFrame_t* mf; /**< J2735 MessageFrame struct */
    int8_t rssi;        /**< rssi of received advertisement */
    uint8_t channel;    /**< channel of received advertisement */
    char* debugString;  /**< misc debug data string */
} serialization_csv_data_t;

/**
 * @brief serialize a logged safety message as csv
 *
 * Does *not* put a newline in
 *
 * @param[out] out      output buffer for csv data
 * @param[out] out_len  number of chars in output
 * @param      out_size size of output
 * @param      data     data to encode
 *
 * @retval SERIALIZATION_OK                       Operation success.
 * @retval SERIALIZATION_DATA_INVALID_UNSUPPORTED If messageframe wasn't a supported type
 * @retval SERIALIZATION_USAGE_BUFFER_TOO_SMALL   If out wasn't big enoguh
 **/
serialization_e serialization_csv_serialize(char* out,
                                            size_t* out_len,
                                            size_t out_size,
                                            serialization_csv_data_t* data);


/**
 * @brief deserialize a csv to a logged safety message
 *
 * @param[out] data  decoded data
 * @param      input string to parse
 *
 * @retval SERIALIZATION_OK                      Operation success.
 * @retval SERIALIZATION_USAGE_PARAM_INVALID     If data->debugString isn't NULL
 * @retval SERIALIZATION_FAIL_ALLOC              If a memory allocation failed.
 * @retval SERIALIZATION_DATA_INVALID_UNPARSABLE If something couldn't be parsed as a number or date or whatever
 * @retval SERIALIZATION_FAIL_LIBSM              If libsm failed in unhandled way.
 * @retval SERIALIZATION_DATA_EMPTY              If a required field was empty
 * @retval SERIALIZATION_DATA_INVALID_RANGE      If a field was outside acceptable ranges.
 **/
serialization_e serialization_csv_deserialize(serialization_csv_data_t* data, char* input);


/**
 * @brief return the CSV column headers
 *
 * @return the csv header string
 **/
const char* serialization_csv_column_header(void);


#endif // SERIALIZATION_CSV_H
