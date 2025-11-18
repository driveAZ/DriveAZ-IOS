#ifndef LIBSM_VERSION_H
#define LIBSM_VERSION_H

#define VERSION_LIBSM_MAJOR 8
#define VERSION_LIBSM_MINOR 0
#define VERSION_LIBSM_PATCH 0

/**
 * LIBSM_VERSION_COMPATIBLE tells you if the current LIBSM is compatible
 * with a requested version.
 *
 *   LIBSM VERSION RULES CHECK FOR THOSE REQUIRING LIBSM
 * LIBSM HAS:
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
#define LIBSM_VERSION_COMPATIBLE(major, minor, patch)                    \
    (((major == VERSION_LIBSM_MAJOR)                                     \
      && ((minor == VERSION_LIBSM_MINOR && patch <= VERSION_LIBSM_PATCH) \
          || (minor < VERSION_LIBSM_MINOR))                              \
      ) ? 1 : 0)

#define LIBSM_VERSION_INCOMPATIBLE(major, minor, patch) \
    (!LIBSM_VERSION_COMPATIBLE(major, minor, patch))

#define STR_HELPER(x) #x
#define STR(x) STR_HELPER(x)
#define VERSION_LIBSM "v"        \
    STR(VERSION_LIBSM_MAJOR) "." \
    STR(VERSION_LIBSM_MINOR) "." \
    STR(VERSION_LIBSM_PATCH)

#endif // LIBSM_VERSION_H
