/**
 * @file
 * @brief Errors used in the serialization library.
 */
#ifndef SERIALIZATION_ERRORS_H
#define SERIALIZATION_ERRORS_H

/**
 * @brief Serialization enum of errors.
 *        Functions should not return _BASE errors.
 *
 * @details You can check for a class of errors with
 *     (ret & SERIALIZATION_DATA_INVALID_BASE)
 * and check individual errors with
 *     (ret == SERIALIZATION_PROCESS_OK_WITH_DATA)
 */
typedef enum {
    SERIALIZATION_OK = 0x00000,

    SERIALIZATION_FAIL_BASE = 0x01000,
    SERIALIZATION_FAIL_ALLOC = 0x01001,
    SERIALIZATION_FAIL_LIBSM = 0x01002, // something we can't handle or report up went wrong

    SERIALIZATION_USAGE_ERROR_BASE = 0x02000,
    SERIALIZATION_USAGE_PARAM_NULL = 0x02001,
    SERIALIZATION_USAGE_PARAM_INVALID = 0x02002,
    SERIALIZATION_USAGE_BUFFER_TOO_SMALL = 0x02003,
    SERIALIZATION_USAGE_NO_MESSAGEFRAME = 0x02004,

    SERIALIZATION_PROCESS_OK_BASE = 0x04000,
    SERIALIZATION_PROCESS_OK_WITH_DATA = 0x04001,
    SERIALIZATION_PROCESS_OK_WITHOUT_DATA = 0x04002,

    SERIALIZATION_DATA_EMPTY = 0x08000,

    SERIALIZATION_DATA_INVALID_BASE = 0x10000,
    SERIALIZATION_DATA_INVALID_CRC_COBS = 0x10001, // cobs or CRC
    // unsupported logFormat2/tsm version, mf with non bsm/psm, etc.
    SERIALIZATION_DATA_INVALID_UNSUPPORTED = 0x10003,
    SERIALIZATION_DATA_INVALID_RANGE = 0x10004,
    // format doesn't match expected in csv or logFormat1 or whatever
    SERIALIZATION_DATA_INVALID_UNPARSABLE = 0x10005,
    SERIALIZATION_DATA_INVALID_SIZE = 0x10006, // tsm comment too big
} serialization_e;


/**
 * @brief Return a text description of the serialization error.
 *
 * @param  error Serialization error enum
 * @return       String containing a description of the error
 */
const char* serialization_error2str(serialization_e error);


#endif // SERIALIZATION_ERRORS_H
