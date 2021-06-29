ifneq ($(BOARD_VENDOR_QCOM_GPS_LOC_API_HARDWARE),)

# Set required flags
GNSS_CFLAGS := \
    -Werror \
    -Wno-unused-parameter \
    -Wno-macro-redefined \
    -Wno-reorder \
    -Wno-missing-braces \
    -Wno-self-assign \
    -Wno-enum-conversion \
    -Wno-logical-op-parentheses \
    -Wno-null-arithmetic \
    -Wno-null-conversion \
    -Wno-parentheses-equality \
    -Wno-undefined-bool-conversion \
    -Wno-tautological-compare \
    -Wno-switch \
    -Wno-date-time

GNSS_HIDL_VERSION = 2.1

GNSS_HIDL_LEGACY_MEASURMENTS_TARGET_LIST += msm8937
GNSS_HIDL_LEGACY_MEASURMENTS_TARGET_LIST += msm8953
GNSS_HIDL_LEGACY_MEASURMENTS_TARGET_LIST += msm8996
GNSS_HIDL_LEGACY_MEASURMENTS_TARGET_LIST += msm8998
GNSS_HIDL_LEGACY_MEASURMENTS_TARGET_LIST += apq8098_latv
GNSS_HIDL_LEGACY_MEASURMENTS_TARGET_LIST += sdm710
GNSS_HIDL_LEGACY_MEASURMENTS_TARGET_LIST += qcs605
GNSS_HIDL_LEGACY_MEASURMENTS_TARGET_LIST += sdm845
GNSS_HIDL_LEGACY_MEASURMENTS_TARGET_LIST += sdm660

ifneq (,$(filter $(GNSS_HIDL_LEGACY_MEASURMENTS_TARGET_LIST),$(TARGET_BOARD_PLATFORM)))
GNSS_HIDL_LEGACY_MEASURMENTS = true
endif

LOCAL_PATH := $(call my-dir)
include $(call all-makefiles-under,$(LOCAL_PATH))

GNSS_SANITIZE := cfi bounds null unreachable integer
# Activate the following two lines for regression testing
#GNSS_SANITIZE += address
#GNSS_SANITIZE_DIAG := $(GNSS_SANITIZE)

endif # ifneq ($(BOARD_VENDOR_QCOM_GPS_LOC_API_HARDWARE),)
