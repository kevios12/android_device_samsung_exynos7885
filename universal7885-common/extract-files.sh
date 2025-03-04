#!/bin/bash
#
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d ${MY_DIR} ]]; then MY_DIR="${PWD}"; fi

LINEAGE_ROOT="${MY_DIR}"/../../..

HELPER="${LINEAGE_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
	echo "Unable to find helper script at ${HELPER}"
	exit 1
fi
source "${HELPER}"

function blob_fixup {
	case "$1" in
	vendor/lib*/libsensorlistener.so)
		grep -q libshim_sensorndkbridge.so "$2" || "$PATCHELF" --add-needed "libshim_sensorndkbridge.so" "$2"
		;;
	vendor/lib*/libcrypto-compat.so)
	    "${PATCHELF}" --set-soname libcrypto-compat.so "${2}"
	esac
}

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

ONLY_COMMON=
ONLY_TARGET=
SECTION=
KANG=

while [ "${#}" -gt 0 ]; do
	case "${1}" in
	--only-common)
		ONLY_COMMON=true
		;;
	--only-target)
		ONLY_TARGET=true
		;;
	-n | --no-cleanup)
		CLEAN_VENDOR=false
		;;
	-k | --kang)
		KANG="--kang"
		;;
	-s | --section)
		SECTION="${2}"
		shift
		CLEAN_VENDOR=false
		;;
	*)
		SRC="${1}"
		;;
	esac
	shift
done

if [ -z "${SRC}" ]; then
	SRC="adb"
fi

# Initialize the helper for common device
if [ -z "${ONLY_TARGET}" ]; then
	# Initialize the helper for common device
	setup_vendor "${DEVICE_COMMON}" "${VENDOR}" "${LINEAGE_ROOT}" true "${CLEAN_VENDOR}"

	extract "${MY_DIR}/proprietary-files.txt" "${SRC}" \
		"${KANG}" --section "${SECTION}"
fi

if [ -z "${ONLY_COMMON}" ] && [ -s "${MY_DIR}/../${DEVICE}/proprietary-files.txt" ]; then
	# Reinitialize the helper for device
	source "${MY_DIR}/../${DEVICE}/extract-files.sh"
	setup_vendor "${DEVICE}" "${VENDOR}" "${LINEAGE_ROOT}" false "${CLEAN_VENDOR}"

	extract "${MY_DIR}/../${DEVICE}/proprietary-files.txt" "${SRC}" \
		"${KANG}" --section "${SECTION}"
fi

"${MY_DIR}/setup-makefiles.sh"
