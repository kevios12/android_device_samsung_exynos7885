# Auto-Generated by device/samsung/a20/setup.sh
$(call inherit-product, device/samsung/a20/full_a20.mk)
$(call inherit-product, vendor/ancient/config/common_full_phone.mk)
PRODUCT_NAME := ancient_a20

# AncientOS Officialy Stuff
ANCIENT_OFFICIAL := true
TARGET_USES_BLUR := true
ANCIENT_GAPPS := false

TARGET_FACE_UNLOCK_SUPPORTED := true
TARGET_BOOT_ANIMATION_RES := 720
