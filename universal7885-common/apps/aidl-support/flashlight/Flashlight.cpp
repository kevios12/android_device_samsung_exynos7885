/*
 * Copyright (C) 2023 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include "Flashlight.h"

#include <android-base/file.h>

#include <mutex>

namespace aidl {
namespace vendor {
namespace samsung_ext {
namespace hardware {
namespace camera {
namespace flashlight {

using ::android::base::ReadFileToString;
using ::android::base::WriteStringToFile;

static constexpr const char *FLASH_ENABLE_NODE =
    "/sys/class/camera/flash/torch_brightness_lvl_enable";
static constexpr const char *FLASH_LVL_NODE =
    "/sys/class/camera/flash/torch_brightness_lvl";
static constexpr const char *FLASH_NODE = "/sys/class/camera/flash/rear_flash";

ndk::ScopedAStatus Flashlight::getCurrentBrightness(int32_t* _aidl_return) {
    std::string value_s;
    int value = -1;

    auto ret = ReadFileToString(FLASH_LVL_NODE, &value_s);
    if (ret) 
	value = std::stoi(value_s);
    else
	return ndk::ScopedAStatus::fromExceptionCode(EX_ILLEGAL_STATE);

    if (value > 10)
	value /= 21;

    *_aidl_return = value;
    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus Flashlight::setBrightness(int32_t level) {
    if (level > 5 || level < 1)
       return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);

    static std::once_flag once;
    std::call_once(once, [] { WriteStringToFile(std::to_string(true), FLASH_ENABLE_NODE); });
    WriteStringToFile(std::to_string(level), FLASH_LVL_NODE);
    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus Flashlight::enableFlash(bool enable) {
    int32_t rc = 0;
    auto ret = getCurrentBrightness(&rc);
    if (ret.isOk()) {
	if (!!rc == enable)
	    return ndk::ScopedAStatus::fromExceptionCode(EX_ILLEGAL_STATE);
    }
    WriteStringToFile(std::to_string(static_cast<int>(enable)), FLASH_NODE);
    return ndk::ScopedAStatus::ok();
}

} // namespace flashlight
} // namespace camera
} // namespace hardware
} // namespace samsung_ext
} // namespace vendor
} // namespace aidl
