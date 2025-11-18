/**
 * @file
 * @brief Header file for all serialization formats
 */

#ifndef SERIALIZATION_H
#define SERIALIZATION_H

#include "stdbool.h"
#include "stddef.h"
#include "stdint.h"

#include "libsm.h"

#include "serialization-defines.h"
#include "serialization-errors.h"
#include "serialization-formatting.h"
#include "version_serialization.h"

#include "serialization-csv.h"
#include "serialization-logFormat1.h"
#include "serialization-logFormat2.h"
#include "serialization-tsm.h"

#endif // SERIALIZATION_H
