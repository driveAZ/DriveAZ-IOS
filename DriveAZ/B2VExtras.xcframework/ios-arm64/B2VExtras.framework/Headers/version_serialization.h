/**
 * @file version_serialization.h
 * @brief Header file that specifies dependency versions
 */

#ifndef VERSION_SERIALIZATION_H
#define VERSION_SERIALIZATION_H

#include "libsm.h"

//these values are updated by the release script
/** major version number */
#define VERSION_SERIALIZATION_MAJOR 6
/** minor version number */
#define VERSION_SERIALIZATION_MINOR 0
/** patch version number */
#define VERSION_SERIALIZATION_PATCH 0

//! @cond
#ifndef STR_HELPER
/// @private
#define STR_HELPER(x) #x
/// @private
#define STR(x) STR_HELPER(x)
#endif
/*! \endcond */

/** full version string */
#define VERSION_SERIALIZATION                                                          \
    "v" STR(VERSION_SERIALIZATION_MAJOR) "." STR(VERSION_SERIALIZATION_MINOR) "." STR( \
            VERSION_SERIALIZATION_PATCH)

/**
 * SERIALIZATION_VERSION_COMPATIBLE tells you if the current SERIALIZATION is compatible
 * with a requested version.
 *
 * different major version                          incompatible
 * same major, smaller minor version than requested incompatible
 * same major, same minor, smaller patch version    incompatible
 * same major, same minor, same patch version       compatible
 * same major, same minor, bigger patch version     compatible
 * same major, bigger minor, any patch version      compatible
 *
 * RETURN: compatible is 1 incompatible is 0
 *
 **/
#define SERIALIZATION_VERSION_COMPATIBLE(major, minor, patch)                            \
    (((major == VERSION_SERIALIZATION_MAJOR)                                             \
      && ((minor == VERSION_SERIALIZATION_MINOR && patch <= VERSION_SERIALIZATION_PATCH) \
          || (minor < VERSION_SERIALIZATION_MINOR)))                                     \
             ? 1                                                                         \
             : 0)

/**
 * Inverse of SERIALIZATION_VERSION_COMPATIBLE
 **/
#define SERIALIZATION_VERSION_INCOMPATIBLE(major, minor, patch) \
    (!SERIALIZATION_VERSION_COMPATIBLE(major, minor, patch))

#if LIBSM_VERSION_INCOMPATIBLE(8, 0, 0)
#error noncompatible version of libsm
#pragma message "VERSION_LIBSM: " VERSION_LIBSM
#endif

#endif // VERSION_SERIALIZATION_H
