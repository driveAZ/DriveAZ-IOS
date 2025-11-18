#ifndef J2945_DEFINES_H
#define J2945_DEFINES_H

/**
 * Preliminary parameter settings for VRU safety
 * These preliminary values are intended for experimental use to determine the
 * appropriate values in future releases of [SAE J2945/9].
 * identified in Table 5 of the J2945/9 standard (Section 6).
 * REFERENCES: J2945/9 2017-03, J2945/1 2020-04
 **/

// J2945/9 Section Reference 6.1, 6.1.4, 6.3.2
// References DSRC Channel, not Bluetooth
#define vruChannelNumber 176

// J2945/9 Section Reference 6.2.1
// Value in Hz
#define vruPosDetRate 1

// J2945/9 Section Reference 6.3.2
// Value in Mbps
#define vruDataRateDefault 6

// J2945/9 Section Reference 6.3.2
// Value in Mbps
#define vruDataRateAlt 9

// J2945/9 Section Reference 6.3.3
// Value in m/s
#define vruPSMTxThreshold 15

// J2945/9 Section Reference 6.3.3
// Value in seconds
#define vruTransmitStartTime 1

// J2945/9 Section Reference 6.3.3
// Value in in/s
#define vruHighSpdPSMTiConst 0.2

// J2945/9 Section Reference 6.3.3
#define vruPSMTiCoeff 0.02

// J2945/9 Section Reference 6.3.3
// Value in ms
#define vruTxRand 5

// J2945/9 Section Reference 6.3.3
// Value in Hz
#define vruPSMTxRateMin 1

// J2945/9 Section Reference 6.3.3
// Value in Hz
#define vruPSMTxRateMax 10

// J2945/9 Section Reference 6.3.3.1
// Value in seconds
#define vruSituationAwareTime 4.5

// J2945/9 Section Reference 6.3.3.1
// Value in meters
#define vruDistanceToRoadway 3

// J2945/9 Section Reference 6.3.5.3
// Value in ms
#define vruTimeAccuracy 1

// J2945/9 Section Reference 6.3.5.5
// Value in ms
#define vruMaxPosAge 500

// J2945/9 Section Reference 6.3.5.6
// Value in meters
#define vruPosAccuracy 1.5

// J2945/9 Section Reference 6.3.5.7
// Value in meters
#define vruElevAccuracy 1.5

// J2945/9 Section Reference 6.3.5.9
// Value in kph
#define vruVelocityAccuracy 2

// J2945/9 Section Reference 6.3.5.10
// Value in degrees
#define vruHeadAccuracy 5

// J2945/9 Section Reference 6.3.5.11
// Value in meters/sec^2
#define vruAccelAccuracy 1

// J2945/9 Section Reference 6.3.5.11
// Value in meters/sec^2
#define vruVertAccelAccuracy 3

// J2945/9 Section Reference 6.3.5.11
// Value in meters/second
#define vruAccTxSpdThresh 15

// J2945/9 Section Reference 6.3.5.11
// Value in seconds
#define vruAccTxTimeThresh 3

// J2945/9 Section Reference 6.3.5.12
// Value in meters
#define vruMinPHistDistance 5

// J2945/9 Section Reference 6.3.5.12
// Value in meters
#define vruMaxPHistDistance 100

// J2945/9 Section Reference 6.3.5.12
// Value in meters/second
#define vruPHistTxSpdThresh 15

// J2945/9 Section Reference 6.3.5.12
// Value in seconds
#define vruPHisTxTimeThresh 3

// J2945/9 Section Reference 6.3.5.12
// Value in meters
#define vruPathPerpendicularDist 1

// J2945/9 Section Reference 6.3.5.12
#define vruMaxPHistPoints 15

// J2945/9 Section Reference 6.3.5.13
// Value in percent
#define vruPPredRadiusError 2

// J2945/9 Section Reference 6.3.5.13
// Value in meters/second
#define vruPPredTxSpdThresh 15

// J2945/9 Section Reference 6.3.5.13
// Value in seconds
#define vruPPredTxTimeThresh 3

// J2945/9 Section Reference 6.3.5.13
// Value in meters
#define vruMinCurveRadius 100

// J2945/9 Section Reference 6.3.5.13
// Value in meters
#define vruMaxCurveRadius 2500

// J2945/9 Section Reference 6.3.5.13
// Value in meters/second
#define vruStationarySpeedThresh 1

// J2945/9 Section Reference 6.3.5.22
// Value in meters
#define vruPersonalClusterRadiusDef 3

// J2945/9 Section Reference 6.5
// Value in seconds
#define vruMaxCertDigestInterval 1

// J2945/9 Section Reference 6.5
// Value in minutes
#define vruCertChangeInterval 5

// J2945/9 Section Reference 6.5
// Value in meters
#define vruCertChangeDistance 100

// In steady state the average of the absolute value of the change
// of yaw rate over time is smaller than 1.0 deg/s
// 6.3.6.17 DF_PathPrediction, J2945/1 APR2020
// Value in degrees/sec^2 (possible misprint of sec^2 ?)
#define steadyStateYawRateDegreesSec = 1.0


/**
 * CHANGES AND CLARIFICATIONS TO REPORT TO THE SAE J2945/1 GROUP:
 * Requested changes to J2945/1
 * 6.3.8.1 Inputs to BSM Scheduling and Congestion Control
 *  It is a mix of paragraphs, bullet points, and possibly accidentally indented
 *  paragraphs
 *  Each input to the congestion control algorithm should get a section number
 *      6.3.8.1.1, 6.3.8.1.2, etc
 *  Does vPERRange affect PER? I'm *fairly* sure it doesn't, and it's just a
 *  weirdly indented paragraph describing vPERRange which is used in Channel
 *  Quality Indicator and Vehicle Density in Range.
 * Appendix 8.3
 *  An example of a high-ish PER would be appreciated so it's easier to check an
 *  implementation approach.
 *  Something like the first subinterval receiving message count 1 and 2, the
 *  second subinterval receiving 12 and 13, etc.
 *  Unrelated, A8.3 refers to IPG and nothing else in J2945/1 mentions it.
 **/

/**
 * The duration, in milliseconds, of a PER sub-interval
 */
#define V_PER_SUBINTERVAL_MS 1000

/**
 * The number of PERSubIntervals that comprise a PER Interval
 * REF: J2945/1
 */
#define PER_SUBINTERVAL_COUNT 5
#define PER_NEWEST_SUBINTERVAL (PER_SUBINTERVAL_COUNT - 1)

// There is no spec'd "unavail" for PER, so 101% seems fine
#define PER_UNAVAILABLE 101

// J2945/1 (2020), Section A.6.5, Table A2
// Low-pass cutoff frequency for curvature filter (Hz) aka "f0".
#define curvatureCutoffFrequency 0.33
// Curvature filter dampening factor aka "Zeta".
#define curvatureDampingFactor  1.0
// Sample time for discrete curvature filter (100 milliseconds = 0.1 second) aka "Ts".
#define curvatureSamplingPeriod 0.1
// Radius upper limit (meters) beyond which the path is considered straight.
#define curvatureMaxRadius 2500.0
// Low-pass cutoff frequency for confidence filter (Hz) aka "f0".
#define confidenceCutoffFrequency 1.0
// Confidence filter dampening factor aka "Zeta".
#define confidenceDampingFactor  1.0
// Sample time for discrete confidence filter (100 milliseconds = 0.1 second) aka "Ts".
#define confidenceSamplingPeriod 0.1

#define curvatureRadiusUnit 10.0
#define curvatureConfidenceUnit 2.0

#endif // J2945_DEFINES_H
