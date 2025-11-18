#ifndef LIBSM_H
#define LIBSM_H

#include "version.h"

#include "libsm-error.h"
#include "j2735-defines.h"
#include "j2945-defines.h"
#include "libsm-pathHistory.h"
#include "PersonalSafetyMessage.h"
#include "MessageFrame.h"
#include "BasicSafetyMessage.h"
#include "BIT_STRING.h"
#include "libsm-per.h"


/**
 * Takes a pointer to a PSM structure you have allocated, allocates any additional things, and fills with "unavailable" values
 * If successful, returns LIBSM_OK.
 * You are responsible for calling ASN_STRUCT_FREE
 * If psm is not initialized, returns LIBSM_FAIL_NULL_ARG
 */
libsm_rval_e libsm_init_psm(PersonalSafetyMessage_t* psm);


libsm_rval_e libsm_init_bsm(BasicSafetyMessage_t* bsm);


/**
 * Function that accepts a UPER-encoded MessageFrame in the buffer, decodes it, and then validates it.
 * To access the PSM, use something like: PersonalSafetyMessage_t PSM = mf->value.choice.PersonalSafetyMessage;
 * NOTE: The caller is responsible for freeing mf with ASN_STRUCT_FREE
 */
libsm_rval_e libsm_decode_messageframe(const uint8_t* encoded, size_t len, MessageFrame_t* mf);


/**
 * Given a mf/psm/bsm and buffer, wrap the psm/bsm in a MessageFrame, then UPER-encode it.
 * If LIBSM_OK is returned, the UPER-encoded message is in encoded and the size of encoded message is *len.
 */
libsm_rval_e libsm_encode_messageframe(MessageFrame_t* mf, uint8_t* encoded, size_t* len);


libsm_rval_e libsm_encode_messageframe_psm(PersonalSafetyMessage_t* psm, uint8_t* encoded, size_t* len);


libsm_rval_e libsm_encode_messageframe_bsm(BasicSafetyMessage_t* bsm, uint8_t* encoded, size_t* len);


/**
 * Function that accepts a long based on values defined in J2735 returns the basic type string
 * Default 0 mapping for unknown if type not found
 */
const char* libsm_str_basic_vehicle_class(BasicVehicleClass_t type);


/**
 * Function that accepts basic type string returns a long based on values defined in J2735
 * Default unavailable for unknown if type not found
 * BasicVehicleClass_t is a long
 */
BasicVehicleClass_t libsm_basic_vehicle_class_from_str(char* type);


/**
 * Function that accepts a long based on values defined in J2735 returns the personal type string
 * Default 0 mapping for unavailable if type not found
 */
const char* libsm_str_personal_device_user_type(PersonalDeviceUserType_t type);


/**
 * Function that converts a string personal device type into its corresponding int
 * Accepts string and returns int
 */
PersonalDeviceUserType_t libsm_personal_device_user_type_from_str(char* deviceType);


/**
 * Function that returns the basic vehicle type for a given BSM
 * Default 0 mapping for unavailable if type not found
 */
BasicVehicleClass_t libsm_get_basic_vehicle_class(BasicSafetyMessage_t* bsm);


/**
 * Function to set the basic vehicle type for a given BSM
 * Accepts the bsm and vehicle type and returns the success or error code accordingly
 * Creates the PartII if no PartII exists on the BSM
 */
libsm_rval_e libsm_set_basic_vehicle_class(BasicSafetyMessage_t* bsm, BasicVehicleClass_t vehicleType);


/**
 * Function that returns the path prediction type for a given BSM
 * Default returns NULL when type is not found
 */
PathPrediction_t* libsm_get_path_prediction(BasicSafetyMessage_t* bsm);


/**
 * Function to set path prediction for a BSM
 * Accepts bsm and the path prediction information
 * Will create partII of BSM if not previously done
 */
libsm_rval_e libsm_set_path_prediction(BasicSafetyMessage_t* bsm, Confidence_t confidence, RadiusOfCurvature_t radius);


/**
 * Given an allocated PSM, allocate a pathHistory dataframe and initialize it
 * if pathHistory does not already exist within the PSM.
 * Returns LIBSM_OK if the PSM already has a pathHistory, or if the insertion
 * of a new pathHistory into the PSM is successful.
 */
libsm_rval_e libsm_init_psm_path_history(PersonalSafetyMessage_t* psm);


/**
 * Given an allocated BSM, allocate a pathHistory dataframe and initialize it
 * if pathHistory does not already exist within the BSM.
 * Because a BSM's pathHistory exists within BSM Part II->VehicleSafetyExtensions,
 * these additional dataframes are allocated and initialized if they do not already
 * exist.
 * Returns LIBSM_OK if the BSM already has a pathHistory, or if the insertion
 * of a new pathHistory into the BSM is successful.
 */
libsm_rval_e libsm_init_bsm_path_history(BasicSafetyMessage_t* bsm);


/**
 * Allocates a DDateTime dataframe and initializes
 * the elements with "unavailable".
 * Returns a pointer to the allocated and initialized
 * DDateTime dataframe, else returns NULL.
 */
DDateTime_t* libsm_alloc_init_DDateTime(void);


/**
 * Allocates a FullPositionVector dataframe and initializes
 * required elements with "unavailable", and OPTIONAL elements with NULL.
 * Returns a pointer to the allocated and initialized
 * FullPositionVector dataframe, else returns NULL.
 */
FullPositionVector_t* libsm_alloc_init_FullPositionVector(void);


/**
 * Allocates a FullPositionVector dataframe and initializes
 * required elements with "unavailable", and OPTIONAL elements with NULL.
 * Returns a pointer to the allocated and initialized
 * FullPositionVector dataframe, else returns NULL.
 */
PathHistoryPoint_t* libsm_alloc_init_PathHistoryPoint(void);


/**
 * Allocates a PathHistory and initializes
 * the elements with "unavailable".
 * Returns a pointer to the allocated and initialized
 * PathHistory, else returns NULL.
 */
PathHistory_t* libsm_alloc_init_path_history(void);


/**
 * Given an allocated BSM, search for a Part II extension.
 * Returns: If found, a pointer to that extension, else NULL.
 */
void* libsm_get_partII_elem(BasicSafetyMessage_t* bsm, BSMpartIIExtension__partII_Value_PR searchFor);


libsm_rval_e libsm_bsm_alloc_partII_if_not_exist(BasicSafetyMessage_t* bsm);


VehicleSafetyExtensions_t* libsm_add_bsm_VehicleSafetyExtension(BasicSafetyMessage_t* bsm);


/*
 * Allocates a AccelerationSet4Way dataframe and initializes
 * the elements with "unavailable".
 * Returns a pointer to the allocated and initialized
 * AccelerationSet4Way dataframe, else returns NULL.
 */
AccelerationSet4Way_t* libsm_alloc_init_AccelerationSet4Way(void);


/**
 * Allocates a PathPrediction dataframe and initializes
 * the elements with "unavailable".
 * Returns a pointer to the allocated and initialized
 * PathPrediction dataframe, else returns NULL.
 */
PathPrediction_t* libsm_alloc_init_PathPrediction(void);


/**
 * Initialize an existing TemporaryID by allocating the buf
 */
libsm_rval_e libsm_init_TemporaryID(TemporaryID_t* id);


/**
 * Allocate and init a bit string of size bits
 **/
BIT_STRING_t* libsm_alloc_init_bit_string(size_t bits);


/**
 * Initialize a bit string of size bits
 **/
libsm_rval_e libsm_init_bit_string(BIT_STRING_t* bit_string, size_t bits);


bool libsm_mf_has_psm(MessageFrame_t const* const mf);


bool libsm_mf_has_bsm(MessageFrame_t const* const mf);


PersonalSafetyMessage_t* libsm_get_psm(MessageFrame_t* const mf);


BasicSafetyMessage_t* libsm_get_bsm(MessageFrame_t* const mf);


/**
 * Allocate and initialize a psm or bsm inside a messageframe
 **/
MessageFrame_t* libsm_alloc_init_mf_psm(void);


MessageFrame_t* libsm_alloc_init_mf_bsm(void);


#ifndef ARRAY_SIZE
// Fancy define to prevent accidentally passing a regular pointer to ARRAY_SIZE
// https://stackoverflow.com/a/29926435/2423187
#define ASSERT_ARRAY(a) \
    sizeof(char[1 - 2 * __builtin_types_compatible_p(__typeof__(a), __typeof__(&(a)[0]))])
#define ARRAY_SIZE(a) \
    (ASSERT_ARRAY(a) * 0 + sizeof(a) / sizeof((a)[0]))
#endif


#endif //LIBSM_H
