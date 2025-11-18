#ifndef J2735_DEFINES_H
#define J2735_DEFINES_H

#include "stdbool.h"


#define RANGE_CHECK_ACTUAL(MIN, MAX, UNAVAILABLE, VAL) (VAL == UNAVAILABLE || (VAL >= MIN && VAL <= MAX))

/**
 * RANGE_CHECK checks if a value is valid for a j2735 field
 **/
#define RANGE_CHECK(NAME, VAL) (RANGE_CHECK_ACTUAL(NAME ## _min, NAME ## _max, NAME ## _unavailable, VAL))

/**
 * RANGE_COERCE_ACTUAL does the range coersion
 * It will mostly be called by RANGE_COERCE
 * SET_UNAVAILABLE is if values outside range should be set to range limits or unavailable
 **/
#define RANGE_COERCE_ACTUAL(MIN, MAX, UNAVAILABLE, SET_UNAVAILABLE, VAL) \
    (RANGE_CHECK_ACTUAL(MIN, MAX, UNAVAILABLE, VAL) ? VAL : (SET_UNAVAILABLE ? UNAVAILABLE : (VAL < MIN ? MIN : MAX)))

/**
 * RANGE_COERCE puts a number in a range based on J2735 type names
 * Pass in a J2735 DE type and it will automagically coerce into that range correctly.
 *
 * Needs libsm to define things, so for Acceleration, we need
 * Acceleration_min, Acceleration_max, Acceleration_unavailable, and Acceleration_setUnavailable defined
 **/
#define RANGE_COERCE(NAME, VAL) \
    RANGE_COERCE_ACTUAL(NAME ## _min, NAME ## _max, NAME ## _unavailable, NAME ## _setUnavailable, VAL)


// All enum values are defined by asn1c in the relevant header files, but not here.
// The contents of this file are for values defined in J2735 but not in the ASN.

// min, max, unavailable are pretty self-explanatory
// setUnavailable is for the RANGE_COERCE macro to know how to handle values outside the range.
// if false, values outside the range will be min or max, if true they will be unavailable
// unit is the factor that we apply to the j2735 number to convert from raw data to human readable units (divide by) and vice versa (multiply by)

#define Acceleration_min -2000
#define Acceleration_max 2000
#define Acceleration_unavailable 2001
#define Acceleration_setUnavailable false
//  0.01 (1/100) m/s^2 <-> m/s^2
#define Acceleration_unit_m_s2 100
#define Acceleration_unit Acceleration_unit_m_s2

#define VerticalAcceleration_min -126
#define VerticalAcceleration_max 127
#define VerticalAcceleration_unavailable -127
#define VerticalAcceleration_setUnavailable false
//  0.02 (1/50) G <-> G
#define VerticalAcceleration_unit_G 50
#define VerticalAcceleration_unit VerticalAcceleration_unit_G

#define YawRate_min -32767
#define YawRate_max 32767
//  0.01 (1/100) deg/s <-> deg/s
#define YawRate_unit YawRate_unit_deg_s
#define YawRate_unit_deg_s 100

#define Latitude_min -900000000
#define Latitude_max 900000000
#define Latitude_unavailable 900000001
#define Latitude_setUnavailable true
//  1/10 microdegrees <-> degrees
#define Latitude_unit_deg 1e7
#define Latitude_unit Latitude_unit_deg

#define Longitude_min -1799999999
#define Longitude_max 1800000000
#define Longitude_unavailable 1800000001
#define Longitude_setUnavailable true
//  1/10 microdegrees <-> degrees
#define Longitude_unit_deg 1e7
#define Longitude_unit Longitude_unit_deg

#define Elevation_min -4095
#define Elevation_max 61439
#define Elevation_unavailable -4096
#define Elevation_setUnavailable false
//  10 cm (1/10 m) <-> m
#define Elevation_unit_m 10
#define Elevation_unit Elevation_unit_m

#define Velocity_min 0
#define Velocity_max 8190
#define Velocity_unavailable 8191
// this one is a judgement call, J2735 doesn't say what to do
#define Velocity_setUnavailable true
//  0.02 (1/50) m/s <-> m/s
#define Velocity_unit_m_s 50
#define Velocity_unit Velocity_unit_m_s

#define Heading_min 0
#define Heading_max 28799
#define Heading_unavailable 28800
#define Heading_setUnavailable true
//  0.0125 (1/80) degrees <-> degrees
#define Heading_unit_deg 80
#define Heading_unit Heading_unit_deg

#define SemiMajorAxisAccuracy_min 0
#define SemiMajorAxisAccuracy_max 254
#define SemiMajorAxisAccuracy_unavailable 255
#define SemiMajorAxisAccuracy_setUnavailable false

#define SemiMinorAxisAccuracy_min 0
#define SemiMinorAxisAccuracy_max 254
#define SemiMinorAxisAccuracy_unavailable 255
#define SemiMinorAxisAccuracy_setUnavailable false

#define SemiMajorAxisOrientation_min 0
#define SemiMajorAxisOrientation_max 65534
#define SemiMajorAxisOrientation_unavailable 65535
#define SemiMajorAxisOrientation_setUnavailable true

#define SteeringWheelAngle_min 0
#define SteeringWheelAngle_max 126
#define SteeringWheelAngle_unavailable 127
#define SteeringWheelAngle_setUnavailable false

#define VehicleWidth_min 1
#define VehicleWidth_max 1023
#define VehicleWidth_unavailable 0
#define VehicleWidth_setUnavailable true

#define VehicleLength_min 1
#define VehicleLength_max 4095
#define VehicleLength_unavailable 0
#define VehicleLength_setUnavailable true

#define DSecond_min 0
#define DSecond_max 65534
#define DSecond_unavailable 65535
#define DSecond_setUnavailable true
#define DSecond_unit 1

#define DYear_min 1
#define DYear_max 4095
#define DYear_unavailable 0
#define DYear_setUnavailable true

#define DMonth_min 1
#define DMonth_max 12
#define DMonth_unavailable 0
#define DMonth_setUnavailable true

#define DDay_min 1
#define DDay_max 31
#define DDay_unavailable 0
#define DDay_setUnavailable true

#define DHour_min 0
#define DHour_max 30
#define DHour_unavailable 31
#define DHour_setUnavailable true

#define DMinute_min 0
#define DMinute_max 59
#define DMinute_unavailable 60
#define DMinute_setUnavailable true

#define DOffset_min -840
#define DOffset_max 840
#define DOffset_unavailable 0
#define DOffset_setUnavailable true

#define RadiusOfCurvature_min -32767
#define RadiusOfCurvature_max 32766
#define RadiusOfCurvature_straight 32767
//  10 cm (1/10 m) <-> m
#define RadiusOfCurvature_unit_m 10
#define RadiusOfCurvature_unit RadiusOfCurvature_unit_m

#define Confidence_max 200
#define Confidence_min 0
#define Confidence_unit 2

#define OffsetLL_B18_min -131071
#define OffsetLL_B18_max 131071
#define OffsetLL_B18_unavailable -131072
#define OffsetLL_B18_setUnavailable false

#define VertOffset_B12_min -2047
#define VertOffset_B12_max 2047
#define VertOffset_B12_unavailable -2048
#define VertOffset_B12_setUnavailable false

#define TimeOffset_min 1
#define TimeOffset_max 65534
#define TimeOffset_unavailable 65535
#define TimeOffset_setUnavailable false

#define MsgCount_min    0
#define MsgCount_max    127
#define MsgCount_unit    1

#endif // J2735_DEFINES_H
