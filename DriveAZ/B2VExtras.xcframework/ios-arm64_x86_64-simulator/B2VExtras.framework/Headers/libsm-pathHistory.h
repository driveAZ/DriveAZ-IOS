#ifndef PATH_HISTORY_H
#define PATH_HISTORY_H

#include "MessageFrame.h"
#include "libsm-error.h"
#include "libsm.h"


/**
 * Function that returns the path history utcTime type for a given PSM
 * Default returns NULL when type is not found
 */
DDateTime_t* libsm_get_psm_path_history_utc_time(PersonalSafetyMessage_t* psm);


/**
 * Function that returns the path history utcTime type for a given BSM
 * Default returns NULL when type is not found
 */
DDateTime_t* libsm_get_bsm_path_history_utc_time(BasicSafetyMessage_t* bsm);


libsm_rval_e libsm_set_path_history_DDateTime_values(PathHistory_t* pathHistory,
                                                     DYear_t        year,
                                                     DMonth_t       month,
                                                     DDay_t         day,
                                                     DHour_t        hour,
                                                     DMinute_t      minute,
                                                     DSecond_t      second,
                                                     DOffset_t      offset);


/**
 * Given an allocated BSM and the timestamp parameters, insert the time parameters
 * into PartII->VehicleSafetyExtension->pathHistory->initialPosition->utcTime.
 * Checks are made for the existence of these dataframes and they are
 * allocated and initialized if they don't exist.
 * Returns: LIBSM_OK if the timestamp has been inserted successfully.
 */
libsm_rval_e libsm_set_bsm_path_history_DDateTime(BasicSafetyMessage_t* bsm,
                                                  DDateTime_t*          date);


libsm_rval_e libsm_set_bsm_path_history_DDateTime_values(BasicSafetyMessage_t*  bsm,
                                                         DYear_t                year,
                                                         DMonth_t               month,
                                                         DDay_t                 day,
                                                         DHour_t                hour,
                                                         DMinute_t              minute,
                                                         DSecond_t              second,
                                                         DOffset_t              offset);


/**
 * Given an allocated PSM and the timestamp parameters, insert the time parameters
 * into psm->pathHistory->initialPosition->utcTime.
 * Checks are made for the existence of these dataframes and they are
 * allocated and initialized if they don't exist.
 * Returns: LIBSM_OK if the timestamp has been inserted successfully.
 */
libsm_rval_e libsm_set_psm_path_history_DDateTime(PersonalSafetyMessage_t*  psm,
                                                  DDateTime_t*              date);


libsm_rval_e libsm_set_psm_path_history_DDateTime_values(PersonalSafetyMessage_t*   psm,
                                                         DYear_t                    year,
                                                         DMonth_t                   month,
                                                         DDay_t                     day,
                                                         DHour_t                    hour,
                                                         DMinute_t                  minute,
                                                         DSecond_t                  second,
                                                         DOffset_t                  offset);


#endif // PATH_HISTORY_H
