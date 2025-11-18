#ifndef LIBSM_PER_H
#define LIBSM_PER_H

#include "stdint.h"
#include "stddef.h"
#include "time.h"

#include "Common_MsgCount.h"
#include "j2945-defines.h"

/** @brief element in per storage array */
typedef struct  {
    Common_MsgCount_t   first;          /**< @brief first msg id seen */
    Common_MsgCount_t   last;           /**< @brief last msg id seen */
    size_t              received;       /**< @brief count of msg id seen */
    struct timespec     window_start;   /**< @brief when this window started */
} PERSlidingInterval_t;


/**
 * Calculate Packet Error Radio (PER) as defined in J2945/1 6.3.8.1 and
 * in A.8.3.
 *
 * Note: This function does not support receiving more than 128 messages
 * within a 5 second interval.
 * This condition we call "Double Rollover" and is not detected by this function.
 * Keep the rate at 10Hz, as prescribed in SAE specs.
 *
 * arr - A PERSlidingInterval_t for the device being measured.
 * returns - A Packet Error Ratio
 */
uint16_t libsm_per_calculate(PERSlidingInterval_t arr[PER_SUBINTERVAL_COUNT]);


/**
 * add msgCount to the PER sliding window array at time now
 * struct timespec* now - The current time
 *
 * Reference: J2945/1 APR2020, section 6.3.8.1, "Inputs to BSM Scheduling and Congestion Control"
 */
void libsm_per_store_recalculate(uint16_t*              devicePER,
                                 PERSlidingInterval_t   arr[PER_SUBINTERVAL_COUNT],
                                 Common_MsgCount_t      msgCnt,
                                 struct timespec*       now);


#endif // LIBSM_PER_H
