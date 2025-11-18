#ifndef PATH_PREDICTION_H
#define PATH_PREDICTION_H

#include "MessageFrame.h"
#include "libsm-error.h"
#include "libsm.h"

typedef struct {
    double  Y_n_minus1;
    double  Y_n_minus2;
    double  u_n_minus1;
    int     initCount;
} libsm_pp_filter_state_t;


/**
 * @brief libsm path prediction radius second order filter.
 *
 * @details Reference: J2945/1 2020-04 Figure A17/A18 page 98/99
 *
 * @param curvature The unfiltered curvature in inverse meters.
 * @param state The current state of the filter
 *
 * @return The filtered radius in the range 0 to curvatureMaxRadius meters.
 **/
double libsm_pp_radius_filter(double curvature, libsm_pp_filter_state_t* const state);


/**
 * @brief libsm path prediction confidence second order filter.
 *
 * @details Reference: J2945/1 2020-04 Figure A17/A18 page 98/99
 *
 * @param yawRate The unfiltered yawRate in degrees/second.
 * @param state The current state of the filter
 *
 * @return The filtered confidence in the range 0 to 100 percent.
 **/
double libsm_pp_confidence_filter(double yawRate, libsm_pp_filter_state_t* const state);


double confidenceLookup(double confidenceFiltered);


/**
 * @brief Path prediction entry point
 *
 * @details References:  J2735, J2945/1, J2945/9
 *          J2735: RadiusOfCurvature ::= INTEGER (-32767..32767), 10cm unit
 *          A straight path to use value of 32767
 *          J2735: Confidence ::= INTEGER (0..200) LSB units of 0.5 percent
 *          J2945/1 Table A3 shows this is based on yaw rate.
 *
 * @param pp Path prediction output.
 * @param speed Vehicle speed in meters per second.
 * @param yawRate Yaw rate in degrees per second.
 */
void libsm_calculatePathPrediction(PathPrediction_t* const pp, double speed, double yawRate);


#endif // PATH_PREDICTION_H
