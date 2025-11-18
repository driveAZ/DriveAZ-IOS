/**
 * @file cobs.h
 * @brief Functions for COBS encoding and decoding
 *
 */
#ifndef COBS_H
#define COBS_H

#include "assert.h"
#include "stddef.h"
#include "stdint.h"

#include "serialization-errors.h"


/**
 * @brief COBS encode data to buffer
 *
 * Does not output delimiter byte
 *
 * @param[out] output      Output buffer for encoded data. Pointer must be provided by the caller
 * @param[out] output_len  Number of encoded bytes. Pointer must be provided by the caller
 * @param      output_size Size of output.
 * @param      input       Data to encode.
 * @param      input_len   Number of bytes of input to encode.
 *
 * @retval SERIALIZATION_OK                     Operation success.
 * @retval SERIALIZATION_USAGE_PARAM_NULL       If output or input was null
 * @retval SERIALIZATION_USAGE_BUFFER_TOO_SMALL If output buffer was too small
 *
 **/
serialization_e cobs_encode(uint8_t* output,
                            size_t* output_len,
                            size_t output_size,
                            const uint8_t* input,
                            size_t input_len);


/**
 * @brief COBS decode data to buffer
 *
 * output and input may be the same memory.
 *
 * @param[out] output      Decoded data buffer. Pointer must be provided by the caller.
 * @param[out] output_len  Length of decoded data.  Pointer must be provided by the caller.
 * @param      output_size Number of bytes output can contain.
 * @param      input       Data to decode (cannot have framing NULL).
 * @param      input_len   Number of bytes to decode.
 *
 * @retval SERIALIZATION_OK                     Operation success.
 * @retval SERIALIZATION_USAGE_PARAM_NULL       If output or input was null
 * @retval SERIALIZATION_DATA_INVALID_CRC_COBS  If data was not in COBS format.
 * @retval SERIALIZATION_USAGE_BUFFER_TOO_SMALL If the output buffer was too small
 **/
serialization_e cobs_decode(uint8_t* output,
                            size_t* output_len,
                            size_t output_size,
                            const uint8_t* input,
                            size_t input_len);


/**
 * @brief Estimates the minimum size to hold a COBS encoded array
 *
 * @param      len length of the current array
 * @return         Number of bytes needed in the array after encoding
 */
size_t cobs_max_space_estimate(size_t len);


/**
 * @brief Decode a COBS array using one buffer
 *
 * @details COBS has overhead, so we know output len is always less than input len.
 *
 * @param[in,out] data       IN:The data to decode(cannot have framing NULL). OUT: The decoded data.
 *                           Pointer must be provided by the caller.
 * @param[out]    output_len Number of decoded bytes. Pointer must be provided by the caller.
 * @param         input_len  The number of bytes to process and data size
 *
 * @return SERIALIZATION_OK or any error from cobs_decode.
 */
serialization_e cobs_decode_inplace(uint8_t* data, size_t* output_len, size_t input_len);


#endif // COBS_H
