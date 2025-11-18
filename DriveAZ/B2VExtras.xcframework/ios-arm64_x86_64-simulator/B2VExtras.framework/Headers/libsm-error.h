#ifndef LIBSM_ERROR_H
#define LIBSM_ERROR_H

typedef enum  {
    LIBSM_OK,                       // Returning without errors.
    LIBSM_OK_CONSTRAINT,            // No error, but one or more fields were out of range and were set to "unavailable".
    LIBSM_FAIL,                     // General failure.
    LIBSM_ALLOC_ERR,                // allocation error.
    LIBSM_FAIL_CONSTRAINT,          // PSM or MessageFrame failed the constraint check.
    LIBSM_FAIL_NULL_ARG,            // A message frame object pointer was NULL.
    LIBSM_FAIL_NO_VALID_PARAMETER,  // The function was passed a NULL pointer to a parameter.
    LIBSM_FAIL_DECODING,            // General failure in decoding a UPER-encoded message.
    LIBSM_FAIL_DECODING_BUFF_SIZE,  // Failure decoding because the buffer was too small or was NULL.
    LIBSM_FAIL_ENCODING,            // General failure in encoding a UPER-encoded message.
    LIBSM_FAIL_ENCODING_BUFF_SIZE,  // Failure encoding because the buffer was too small or was NULL.
    LIBSM_FAIL_NO_ARGUMENT          // There was a NULL pointer to the argument.
} libsm_rval_e;


/**
 * Turns an error enum into a string
 **/
const char* libsm_str_err(libsm_rval_e err);


#endif // LIBSM_ERROR_H
