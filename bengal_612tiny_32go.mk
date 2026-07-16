TARGET_BOARD_PLATFORM := bengal
TARGET_BOARD_SUFFIX := _612tiny_32go
TARGET_BOARD_FAMILY := f-bengal
TARGET_BOOTLOADER_BOARD_NAME := bengal

BUILD_BROKEN_DUP_RULES := true
ALLOW_MISSING_DEPENDENCIES := true
RELAX_USES_LIBRARY_CHECK := true

#Flag to Enable 64 bit only configurayion
TARGET_SUPPORTS_64_BIT_ONLY := true

# Enable AVB 2.0
BOARD_AVB_ENABLE := true

# Default Android A/B configuration
ENABLE_AB ?= true

# Enable virtual A/B
ENABLE_VIRTUAL_AB := true

# Enable virtual A/B compression
$(call inherit-product, $(SRC_TARGET_DIR)/product/generic_ramdisk.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/vabc_features.mk)
PRODUCT_VIRTUAL_AB_COMPRESSION_METHOD := lz4
PRODUCT_VENDOR_PROPERTIES += ro.virtual_ab.compression.threads=true

# Enable debugfs restrictions
PRODUCT_SET_DEBUGFS_RESTRICTIONS := true

SYSTEMEXT_SEPARATE_PARTITION_ENABLE = true

# Enable Dynamic partition
BOARD_DYNAMIC_PARTITION_ENABLE ?= true

# Enable Fuse FS
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)
# Enable Fuse Passthrough
PRODUCT_PROPERTY_OVERRIDES += persist.sys.fuse.passthrough.enable=true

SHIPPING_API_LEVEL := 36
PRODUCT_SHIPPING_API_LEVEL := 36

# Set GRF/Vendor freeze properties
BOARD_SHIPPING_API_LEVEL := 202504
#Enable SMCI-Listeners.
TARGET_ENABLE_SMCI_SYSLISTENER := true
# For QSSI builds, we should skip building the system image. Instead we build the
# "non-system" images (that we support).

PRODUCT_BUILD_SYSTEM_IMAGE := false
PRODUCT_BUILD_SYSTEM_OTHER_IMAGE := false
PRODUCT_BUILD_SYSTEM_DLKM_IMAGE := true
PRODUCT_BUILD_VENDOR_IMAGE := true
PRODUCT_BUILD_VENDOR_DLKM_IMAGE := true
PRODUCT_BUILD_PRODUCT_IMAGE := false
PRODUCT_BUILD_PRODUCT_SERVICES_IMAGE := false
PRODUCT_BUILD_ODM_IMAGE := true
ifeq ($(ENABLE_AB), true)
PRODUCT_BUILD_CACHE_IMAGE := false
else
PRODUCT_BUILD_CACHE_IMAGE := true
endif
PRODUCT_BUILD_RAMDISK_IMAGE := true
PRODUCT_BUILD_RECOVERY_IMAGE := true
PRODUCT_BUILD_USERDATA_IMAGE := true

TARGET_SKIP_OTA_PACKAGE := true

#BUILD_BROKEN_PHONY_TARGETS := true
BUILD_BROKEN_DUP_RULES := true
TEMPORARY_DISABLE_PATH_RESTRICTIONS := true
#export TEMPORARY_DISABLE_PATH_RESTRICTIONS

ifneq ($(strip $(BOARD_DYNAMIC_PARTITION_ENABLE)),true)
# Enable chain partition for system, to facilitate system-only OTA in Treble.
BOARD_AVB_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_SYSTEM_ALGORITHM := SHA256_RSA2048
BOARD_AVB_SYSTEM_ROLLBACK_INDEX := 0
BOARD_AVB_SYSTEM_ROLLBACK_INDEX_LOCATION := 2
else
PRODUCT_USE_DYNAMIC_PARTITIONS := true
PRODUCT_PACKAGES += fastbootd
# Add default implementation of fastboot AIDL.
PRODUCT_PACKAGES += android.hardware.fastboot-service.example_recovery

# diag-router
TARGET_HAS_DIAG_ROUTER := true

# f2fs utilities
PRODUCT_PACKAGES += \
 sg_write_buffer \
 f2fs_io \
 check_f2fs

# Userdata checkpoint
PRODUCT_PACKAGES += \
 checkpoint_gc

# Userdata checkpoint start
AB_OTA_POSTINSTALL_CONFIG += \
RUN_POSTINSTALL_vendor=true \
POSTINSTALL_PATH_vendor=bin/checkpoint_gc \
FILESYSTEM_TYPE_vendor=ext4 \
POSTINSTALL_OPTIONAL_vendor=true
# Userdata checkpoint end

ifeq ($(ENABLE_AB),true)
ifeq ($(SYSTEMEXT_SEPARATE_PARTITION_ENABLE), true)
PRODUCT_COPY_FILES += $(LOCAL_PATH)/default/fstab_AB_dynamic_partition.qti:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/first_stage_ramdisk/fstab.default
PRODUCT_COPY_FILES += $(LOCAL_PATH)/emmc/fstab_AB_dynamic_partition.qti:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/first_stage_ramdisk/fstab.emmc
else
PRODUCT_COPY_FILES += $(LOCAL_PATH)/fstab_noSysext.qcom:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/first_stage_ramdisk/fstab.qcom
endif
else
ifeq ($(SYSTEMEXT_SEPARATE_PARTITION_ENABLE), true)
PRODUCT_COPY_FILES += $(LOCAL_PATH)/default/fstab_non_AB_dynamic_partition.qti:$(TARGET_COPY_OUT_RAMDISK)/fstab.default
PRODUCT_COPY_FILES += $(LOCAL_PATH)/emmc/fstab_non_AB_dynamic_partition.qti:$(TARGET_COPY_OUT_RAMDISK)/fstab.emmc
else
PRODUCT_COPY_FILES += $(LOCAL_PATH)/fstab_non_AB_noSysext.qcom:$(TARGET_COPY_OUT_RAMDISK)/fstab.qcom
endif
endif
BOARD_AVB_VBMETA_SYSTEM := system
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := SHA256_RSA2048
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 2
endif

ifneq ("$(wildcard device/qcom/$(TARGET_BOARD_PLATFORM)-kernel/vendor_dlkm/system_dlkm.modules.blocklist)", "")
PRODUCT_COPY_FILES += device/qcom/$(TARGET_BOARD_PLATFORM)-kernel/vendor_dlkm/system_dlkm.modules.blocklist:$(TARGET_COPY_OUT_VENDOR_DLKM)/lib/modules/system_dlkm.modules.blocklist
endif

BOARD_HAVE_BLUETOOTH := false
BOARD_HAVE_QCOM_FM := true
TARGET_DISABLE_PERF_OPTIMIATIONS := false

TARGET_ENABLE_QC_AV_ENHANCEMENTS := true

# Enable incremental FS feature
PRODUCT_PROPERTY_OVERRIDES += ro.incremental.enable=1

PRODUCT_PACKAGES += init.qti.early_init.sh
PRODUCT_PROPERTY_OVERRIDES += \
    ro.soc.manufacturer=QTI

# privapp-permissions whitelisting (To Fix CTS :privappPermissionsMustBeEnforced)
PRODUCT_PROPERTY_OVERRIDES += ro.control_privapp_permissions=enforce

TARGET_DEFINES_DALVIK_HEAP := true

$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, device/qcom/vendor-common/common64.mk)
$(call inherit-product, frameworks/native/build/phone-xhdpi-6144-dalvik-heap.mk)

# Target naming
PRODUCT_NAME := bengal_612tiny_32go
PRODUCT_DEVICE := bengal_612tiny_32go
PRODUCT_BRAND := qti
PRODUCT_MODEL := Bengal for arm64

TARGET_USES_AOSP := false
TARGET_USES_AOSP_FOR_AUDIO := false
TARGET_USES_QCOM_BSP := false

# beluga settings
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.beluga.p=0x3 \
    ro.vendor.beluga.c=0x4800 \
    ro.vendor.beluga.s=0x900 \
    ro.vendor.beluga.t=0x240

# RRO configuration
TARGET_USES_RRO := true

TARGET_DISABLE_DISPLAY := false
TARGET_NO_QSH_WWAN_SUPPORT := true

PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := false

###########
#QMAA flags starts
###########
#QMAA global flag for modular architecture
#true means QMAA is enabled for system
#false means QMAA is disabled for system

TARGET_USES_QMAA := true

#QMAA flag which is set to incorporate any generic dependencies
#required for the boot to UI flow in a QMAA enabled target.
#Set to false when all target level depenencies are met with
#actual full blown implementations.
TARGET_USES_QMAA_RECOMMENDED_BOOT_CONFIG := true

#QMAA tech team flag to override global QMAA per tech team
#true means overriding global QMAA for this tech area
#false means using global, no override
TARGET_USES_QMAA_OVERRIDE_RPMB := true
TARGET_USES_QMAA_OVERRIDE_SMCINVOKE := true
TARGET_USES_QMAA_OVERRIDE_GPT := true
TARGET_USES_QMAA_OVERRIDE_DISPLAY := true
# Set to true
TARGET_USES_QMAA_OVERRIDE_AUDIO   := false
TARGET_USES_QMAA_OVERRIDE_VIDEO   := true
TARGET_USES_QMAA_OVERRIDE_CAMERA  := true
TARGET_USES_QMAA_OVERRIDE_GFX     := true
TARGET_USES_QMAA_OVERRIDE_WFD     := true
TARGET_USES_QMAA_OVERRIDE_GPS     := true
TARGET_USES_QMAA_OVERRIDE_ANDROID_RECOVERY := true
TARGET_USES_QMAA_OVERRIDE_ANDROID_CORE := true
TARGET_USES_QMAA_OVERRIDE_WLAN    := true
TARGET_USES_QMAA_OVERRIDE_DPM  := true
TARGET_USES_QMAA_OVERRIDE_BLUETOOTH   := true
TARGET_USES_QMAA_OVERRIDE_BLUETOOTH_AUDIO  := true
TARGET_USES_QMAA_OVERRIDE_FM  := true
TARGET_USES_QMAA_OVERRIDE_CVP  := false
TARGET_USES_QMAA_OVERRIDE_FASTCV  := true
TARGET_USES_QMAA_OVERRIDE_FASTRPC := true
TARGET_USES_QMAA_OVERRIDE_SCVE  := false
TARGET_USES_QMAA_OVERRIDE_OPENVX  := false
TARGET_USES_QMAA_OVERRIDE_DIAG := true
TARGET_USES_QMAA_OVERRIDE_FTM := true
TARGET_USES_QMAA_OVERRIDE_DATA := true
TARGET_USES_QMAA_OVERRIDE_DATA_NET := true
TARGET_USES_QMAA_OVERRIDE_DATA_CONNECTIVITY := true
TARGET_USES_QMAA_OVERRIDE_RIL_DATA := true
TARGET_USES_QMAA_OVERRIDE_KERNEL_TESTS_INTERNAL := true
TARGET_USES_QMAA_OVERRIDE_MSMIRQBALANCE := true
TARGET_USES_QMAA_OVERRIDE_MSM_BUS_MODULE := true
TARGET_USES_QMAA_OVERRIDE_VIBRATOR := true
TARGET_USES_QMAA_OVERRIDE_DRM     := true
TARGET_USES_QMAA_OVERRIDE_KMGK := true
TARGET_USES_QMAA_OVERRIDE_VPP := false
TARGET_USES_QMAA_OVERRIDE_GP := true
TARGET_USES_QMAA_OVERRIDE_BIOMETRICS := true
TARGET_USES_QMAA_OVERRIDE_SPCOM_UTEST := false
TARGET_USES_QMAA_OVERRIDE_PERF := true
TARGET_USES_QMAA_OVERRIDE_SENSORS := true
TARGET_USES_QMAA_OVERRIDE_SYNX := false
TARGET_USES_QMAA_OVERRIDE_SECUREMSM_TESTS := true
TARGET_USES_QMAA_OVERRIDE_SOTER := false
TARGET_USES_QMAA_OVERRIDE_REMOTE_EFS := true
TARGET_USES_QMAA_OVERRIDE_TFTP := true
TARGET_USES_QMAA_OVERRIDE_EID := true
TARGET_USES_QMAA_OVERRIDE_USB := true

TARGET_ENABLE_QSEECOM := false
#Full QMAA HAL List
QMAA_HAL_LIST := audio video camera display sensors gps

ifeq ($(TARGET_USES_QMAA), true)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.confqmaa=true
endif

###########
#QMAA flags ends

JAVA_IN_VENDOR_SOONG_WHITE_LIST :=\
CuttlefishService\
pasrservice\
VendorPrivAppPermissionTest\
MediaDrmAPITest\
CastSignAPITest\

JAVA_IN_VENDOR_MAKE_WHITE_LIST :=\
AEye\
AON\
SnapdragonCamera\

# Set kernel version and ion flags
TARGET_KERNEL_VERSION := 5.15
TARGET_USES_NEW_ION := true

# Disable DLKM generation until build support is available
TARGET_KERNEL_DLKM_DISABLE := true

# Tech specific flags
TARGET_KERNEL_DLKM_AUDIO_OVERRIDE := false
TARGET_KERNEL_DLKM_BT_OVERRIDE := true
TARGET_KERNEL_DLKM_CAMERA_OVERRIDE := true
TARGET_KERNEL_DLKM_NFC_OVERRIDE := true
TARGET_KERNEL_DLKM_ESE_OVERRIDE := false
TARGET_KERNEL_DLKM_DATA_OVERRIDE := true
TARGET_KERNEL_DLKM_DISPLAY_OVERRIDE := true
TARGET_KERNEL_DLKM_MM_DRV_OVERRIDE := true
TARGET_KERNEL_DLKM_SECURE_MSM_OVERRIDE := true
TARGET_KERNEL_DLKM_SECUREMSM_QTEE_OVERRIDE := true
TARGET_KERNEL_DLKM_LIMITS_OVERRIDE := false
TARGET_KERNEL_DLKM_TOUCH_OVERRIDE := true
TARGET_KERNEL_DLKM_VIDEO_OVERRIDE := true
TARGET_KERNEL_DLKM_WLAN_OVERRIDE := true
TARGET_KERNEL_DLKM_MMRM_OVERRIDE := false
TARGET_KERNEL_DLKM_DATARMNET_OVERRIDE := true
TARGET_KERNEL_DLKM_DATARMNETEXT_OVERRIDE := true
TARGET_KERNEL_DLKM_SYNX_OVERRIDE := false
TARGET_KERNEL_DLKM_DATAIPA_OVERRIDE := true
TARGET_KERNEL_DLKM_FASTRPC_OVERRIDE := true
TARGET_KERNEL_DLKM_EVA_OVERRIDE := false
TARGET_KERNEL_DLKM_SPU_OVERRIDE := false
TARGET_KERNEL_DLKM_SAT_MODULE_OVERRIDE := true

#Suppot to compile recovery without msm headers
TARGET_HAS_GENERIC_KERNEL_HEADERS := true

###########
# Target configurations

QCOM_BOARD_PLATFORMS += bengal

TARGET_USES_QSSI := true

#Default vendor image configuration
ENABLE_VENDOR_IMAGE := true

# default is nosdcard, S/W button enabled in resource
PRODUCT_CHARACTERISTICS := nosdcard

BOARD_FRP_PARTITION_NAME := frp

# Android EGL implementation
PRODUCT_PACKAGES += libGLES_android

PRODUCT_PACKAGES += fs_config_files
PRODUCT_PACKAGES += gpio-keys.kl
PRODUCT_PACKAGES += libvolumelistener

ifeq ($(ENABLE_AB), true)
# A/B related packages
PRODUCT_PACKAGES += update_engine \
    update_engine_client \
    update_verifier \
    android.hardware.boot-service.qti \
    android.hardware.boot-service.qti.recovery

PRODUCT_HOST_PACKAGES += \
    brillo_update_payload

# Boot control HAL test app
PRODUCT_PACKAGES_DEBUG += bootctl

PRODUCT_PACKAGES += \
  update_engine_sideload

endif
DEVICE_FRAMEWORK_MANIFEST_FILE := device/qcom/bengal_612tiny_32go/framework_manifest.xml

DEVICE_MANIFEST_FILE := device/qcom/bengal_612tiny_32go/manifest.xml
DEVICE_MATRIX_FILE   := device/qcom/common/compatibility_matrix.xml

# Enable compilation of image_generation_tool
TARGET_USES_IMAGE_GEN_TOOL := true

# Kernel modules install path
KERNEL_MODULES_INSTALL := dlkm
KERNEL_MODULES_OUT := out/target/product/$(PRODUCT_NAME)/$(KERNEL_MODULES_INSTALL)/lib/modules

# MIDI feature
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.midi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.midi.xml

#target specific runtime prop for qspm
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.qspm.enable=true

#FEATURE_OPENGLES_EXTENSION_PACK support string config file
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.opengles.aep.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.opengles.aep.xml


# MIDI feature
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.midi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.midi.xml

#Enable full treble flag
PRODUCT_FULL_TREBLE_OVERRIDE := true
PRODUCT_VENDOR_MOVE_ENABLED := true
PRODUCT_COMPATIBLE_PROPERTY_OVERRIDE := true

ifeq (true,$(BUILDING_WITH_VSDK))
    ALLOW_MISSING_DEPENDENCIES := true
    TARGET_SKIP_CURRENT_VNDK := true
    -include vendor/qcom/vsdk_snapshots_config/config.mk
else
    RECOVERY_SNAPSHOT_VERSION := current
    RAMDISK_SNAPSHOT_VERSION := current
endif

$(warning "BOARD_VNDK_VERSION = $(BOARD_VNDK_VERSION), RECOVERY_SNAPSHOT_VERSION=$(RECOVERY_SNAPSHOT_VERSION), RAMDISK_SNAPSHOT_VERSION=$(RAMDISK_SNAPSHOT_VERSION)")

# Disable QESDK
PRODUCT_ENABLE_QESDK := false

TARGET_MOUNT_POINTS_SYMLINKS := false

PRODUCT_BOOT_JARS += telephony-ext
PRODUCT_PACKAGES += telephony-ext

PRODUCT_BOOT_JARS += tcmiface

# Vendor property to enable advanced network scanning
PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.radio.enableadvancedscan=true

# Property to disable ZSL mode
PRODUCT_PROPERTY_OVERRIDES += \
    camera.disable_zsl_mode=1

PRODUCT_PROPERTY_OVERRIDES += \
ro.crypto.volume.filenames_mode = "aes-256-cts" \
ro.crypto.allow_encrypt_override = true

PRODUCT_PACKAGES += init.qti.dcvs.sh
PRODUCT_PACKAGES += android.hardware.lights-service.qti

#----------------------------------------------------------------------
# wlan specific
#----------------------------------------------------------------------
ifeq ($(TARGET_USES_QMAA), true)
ifneq ($(TARGET_USES_QMAA_OVERRIDE_WLAN), true)
include device/qcom/wlan/default/wlan.mk
else
include device/qcom/wlan/bengal/wlan.mk
endif
else
include device/qcom/wlan/bengal/wlan.mk
endif

#------------------------
# location specific
#------------------------
BOARD_VENDOR_QCOM_GPS_LOC_API_HARDWARE := default
FEATURE_SLIM_AP := false
FEATURE_GPS_LOC_QSH := false

# Enable support for APEX updates
$(call inherit-product, $(SRC_TARGET_DIR)/product/updatable_apex.mk)

###################################################################################
# This is the End of target.mk file.
# Now, Pickup other split product.mk files:
###################################################################################
$(foreach vdefs, $(sort $(wildcard vendor/qcom/defs/product-defs/vendor/*.mk)), \
    $(call inherit-product, $(vdefs)))
###################################################################################
