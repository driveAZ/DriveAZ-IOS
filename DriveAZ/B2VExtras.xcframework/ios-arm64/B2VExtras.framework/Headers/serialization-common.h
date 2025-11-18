/**
 * @file serialization-common.h
 * @brief Macros and defines common to serialization functions.
 *
 */
#ifndef SERIALIZATION_COMMON_H
#define SERIALIZATION_COMMON_H

#include "stdbool.h"
#include "stddef.h"

#ifndef RSSI_MIN
#define RSSI_MIN (-127) /**< RSSI Minimum value */
#endif
#ifndef RSSI_MAX
#define RSSI_MAX 0 /**< RSSI Maximum value */
#endif

#ifndef CHANNEL_MIN
#define CHANNEL_MIN 0 /**< BLE lowest channel */
#endif
#ifndef CHANNEL_MAX
#define CHANNEL_MAX 39 /**< BLE highest channel */
#endif

/**
 * @brief Macro to detect null and zero length strings
 */
#define STRING_IS_EMPTY(str) ((str == NULL) || strlen(str) == 0)

#ifndef ARRAY_SIZE
// REFERENCE: https://stackoverflow.com/a/29926435/2423187
/**
 * @brief Detect if the array a is actually a pointer
 */
#define ASSERT_ARRAY(a) \
    sizeof(char[1 - 2 * __builtin_types_compatible_p(__typeof__(a), __typeof__(&(a)[0]))])
/**
 * @brief Return the array size, ensuring that "a" isn't a pointer
 */
#define ARRAY_SIZE(a) (ASSERT_ARRAY(a) * 0 + sizeof(a) / sizeof((a)[0]))
#endif

/**
 * @brief get data from a PSM/BSM MF
 *
 * Given a messageframe that contains a PSM or a BSM, get the data from PSM_PATH/BSM_PATH
 **/
#define EXTRACT_PSM_BSM_DATA(MF, PSM_PATH, BSM_PATH) *EXTRACT_PSM_BSM_PTR(MF, PSM_PATH, BSM_PATH)

/**
 * @brief get a pointer from a PSM/BSM MF
 *
 * Given a messageframe that contains a PSM or a BSM, get a pointer to PSM_PATH/BSM_PATH
 **/
#define EXTRACT_PSM_BSM_PTR(MF, PSM_PATH, BSM_PATH)                      \
    ((MF->value.present == MessageFrame__value_PR_PersonalSafetyMessage) \
             ? &MF->value.choice.PersonalSafetyMessage.PSM_PATH          \
             : &MF->value.choice.BasicSafetyMessage.BSM_PATH)


/**
 * @brief snprintf into buf at an offset of *cur, add bytes written to *cur
 *
 * has the attribute stuff because clang needs to be told this is a printf like function or it errors
 * Docs are here: http://gcc.gnu.org/onlinedocs/gcc/Common-Function-Attributes.html#Common-Function-Attributes
 * search for format (archetype, string-index, first-to-check)
 *
 * @param[out]    buf      buf to write string into
 * @param[out]    buf_size length of buf
 * @param[in,out] cur      where in buf to keep writing, and output for current place
 * @param         format   format string to use
 * @return                 was the string truncated?
 **/
bool sprintf_fail_on_trunc(char* buf, size_t buf_size, size_t* cur, const char* format, ...)
        __attribute__((format(printf, 4, 5)));


#endif // SERIALIZATION_COMMON_H
