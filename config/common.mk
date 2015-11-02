PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

PRODUCT_PROPERTY_OVERRIDES += \
    keyguard.no_require_sim=true \
    ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
    ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
    ro.com.android.wifi-watchlist=GoogleGuest \
    ro.setupwizard.enterprise_mode=1 \
    ro.com.android.dateformat=MM-dd-yyyy \
    ro.com.android.dataroaming=false

PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.selinux=1

# Disable excessive dalvik debug messages
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.debug.alloc=0

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/razor/prebuilt/common/bin/backuptool.sh:install/bin/backuptool.sh \
    vendor/razor/prebuilt/common/bin/backuptool.functions:install/bin/backuptool.functions \
    vendor/razor/prebuilt/common/bin/50-razor.sh:system/addon.d/50-razor.sh \
    vendor/razor/prebuilt/common/bin/99-backup.sh:system/addon.d/99-backup.sh \
    vendor/razor/prebuilt/common/etc/backup.conf:system/etc/backup.conf

# Signature compatibility validation
PRODUCT_COPY_FILES += \
    vendor/razor/prebuilt/common/bin/otasigcheck.sh:install/bin/otasigcheck.sh

# RAZOR-specific init file
PRODUCT_COPY_FILES += \
    vendor/razor/prebuilt/common/etc/init.local.rc:root/init.razor.rc

# Copy latinime for gesture typing
PRODUCT_COPY_FILES += \
    vendor/razor/prebuilt/common/lib/libjni_latinimegoogle.so:system/lib/libjni_latinimegoogle.so

# SELinux filesystem labels
PRODUCT_COPY_FILES += \
    vendor/razor/prebuilt/common/etc/init.d/50selinuxrelabel:system/etc/init.d/50selinuxrelabel

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Don't export PS1 in /system/etc/mkshrc.
PRODUCT_COPY_FILES += \
    vendor/razor/prebuilt/common/etc/mkshrc:system/etc/mkshrc \
    vendor/razor/prebuilt/common/etc/sysctl.conf:system/etc/sysctl.conf

PRODUCT_COPY_FILES += \
    vendor/razor/prebuilt/common/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/razor/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit \
    vendor/razor/prebuilt/common/bin/sysinit:system/bin/sysinit

# Embed SuperUser
SUPERUSER_EMBEDDED := true

# Required packages
PRODUCT_PACKAGES += \
    CellBroadcastReceiver \
    Development \
    SpareParts \
    Superuser \
    su

# Optional packages
PRODUCT_PACKAGES += \
    Basic \
    LiveWallpapersPicker \
    PhaseBeam

# AudioFX
PRODUCT_PACKAGES += \
    AudioFX \
    Eleven

# CM Hardware Abstraction Framework
PRODUCT_PACKAGES += \
    org.cyanogenmod.hardware \
    org.cyanogenmod.hardware.xml

# Extra Optional packages
PRODUCT_PACKAGES += \
    SlimOTA \
    SlimLauncher \
    LatinIME \
    BluetoothExt \
    DashClock \
    LockClock \
    OmniSwitch

# Screen recorder
PRODUCT_PACKAGES += \
    ScreenRecorder \
    libscreenrecorder

#    SlimFileManager removed until updated
# Extra tools
PRODUCT_PACKAGES += \
    openvpn \
    e2fsck \
    mke2fs \
    tune2fs \
    mount.exfat \
    fsck.exfat \
    mkfs.exfat \
    ntfsfix \
    ntfs-3g

# Stagefright FFMPEG plugin
PRODUCT_PACKAGES += \
    libffmpeg_extractor \
    libffmpeg_omx \
    media_codecs_ffmpeg.xml

PRODUCT_PROPERTY_OVERRIDES += \
    media.sf.omx-plugin=libffmpeg_omx.so \
    media.sf.extractor-plugin=libffmpeg_extractor.so

# easy way to extend to add more packages
-include vendor/extra/product.mk

PRODUCT_PACKAGE_OVERLAYS += vendor/razor/overlay/common

# Boot animation include
ifneq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))

# determine the smaller dimension
TARGET_BOOTANIMATION_SIZE := $(shell \
  if [ $(TARGET_SCREEN_WIDTH) -lt $(TARGET_SCREEN_HEIGHT) ]; then \
    echo $(TARGET_SCREEN_WIDTH); \
  else \
    echo $(TARGET_SCREEN_HEIGHT); \
  fi )

# get a sorted list of the sizes
bootanimation_sizes := $(subst .zip,, $(shell ls vendor/razor/prebuilt/common/bootanimation))
bootanimation_sizes := $(shell echo -e $(subst $(space),'\n',$(bootanimation_sizes)) | sort -rn)

# find the appropriate size and set
define check_and_set_bootanimation
$(eval TARGET_BOOTANIMATION_NAME := $(shell \
  if [ -z "$(TARGET_BOOTANIMATION_NAME)" ]; then
    if [ $(1) -le $(TARGET_BOOTANIMATION_SIZE) ]; then \
      echo $(1); \
      exit 0; \
    fi;
  fi;
  echo $(TARGET_BOOTANIMATION_NAME); ))
endef
$(foreach size,$(bootanimation_sizes), $(call check_and_set_bootanimation,$(size)))

ifeq ($(TARGET_BOOTANIMATION_HALF_RES),true)
PRODUCT_COPY_FILES += \
    vendor/razor/prebuilt/common/bootanimation/halfres/$(TARGET_BOOTANIMATION_NAME).zip:system/media/bootanimation.zip
else
PRODUCT_COPY_FILES += \
    vendor/razor/prebuilt/common/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip:system/media/bootanimation.zip
endif
endif

# Adaway
PRODUCT_COPY_FILES += \
        vendor/razor/prebuilt/common/app/adaway.apk:system/app/adaway.apk

# LayersManager
PRODUCT_COPY_FILES += \
        vendor/razor/prebuilt/common/app/com.lovejoy777.rroandlayersmanager-12.apk:system/app/LayersManager/com.lovejoy777.rroandlayersmanager-12.apk

# SuperSU
PRODUCT_COPY_FILES += \
        vendor/razor/prebuilt/common/UPDATE-SuperSU.zip:system/addon.d/UPDATE-SuperSU.zip \
        vendor/razor/prebuilt/common/etc/init.d/99SuperSUDaemon:system/etc/init.d/99SuperSUDaemon

# Versioning System
# RazorLP first version.
PRODUCT_VERSION_MAJOR = 5.1.1
PRODUCT_VERSION_MINOR = RC
PRODUCT_VERSION_MAINTENANCE = 2.5
ifdef RAZOR_BUILD_EXTRA
    RAZOR_POSTFIX := -$(RAZOR_BUILD_EXTRA)
endif
ifndef RAZOR_BUILD_TYPE
ifeq ($(RAZOR_RELEASE),true)
    RAZOR_BUILD_TYPE := OFFICIAL
    PLATFORM_VERSION_CODENAME := OFFICIAL
    RAZOR_POSTFIX := -$(shell date +"%Y%m%d")
endif
ifeq ($(BUILD_TYPE),WEEKLY)
    RAZOR_BUILD_TYPE := WEEKLY
    PLATFORM_VERSION_CODENAME := WEEKLY
    RAZOR_POSTFIX := -$(shell date +"%Y%m%d")
else
    RAZOR_BUILD_TYPE := UNOFFICIAL
    PLATFORM_VERSION_CODENAME := UNOFFICIAL
    RAZOR_POSTFIX := -$(shell date +"%Y%m%d-%H%M")
endif
endif

# Set all versions
RAZOR_VERSION := TEAM-RAZOR-$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(PRODUCT_VERSION_MAINTENANCE)-$(RAZOR_BUILD_TYPE)$(RAZOR_POSTFIX)
RAZOR_MOD_VERSION := TEAM-RAZOR-$(RAZOR_BUILD)-$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(PRODUCT_VERSION_MAINTENANCE)-$(RAZOR_BUILD_TYPE)$(RAZOR_POSTFIX)

PRODUCT_PROPERTY_OVERRIDES += \
    BUILD_DISPLAY_ID=$(BUILD_ID) \
    razor.ota.version=$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE) \
    ro.razor.version=$(RAZOR_VERSION) \
    ro.modversion=$(RAZOR_MOD_VERSION) \
    ro.razor.buildtype=$(RAZOR_BUILD_TYPE)

EXTENDED_POST_PROCESS_PROPS := vendor/razor/tools/razor_process_props.py

