#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2019 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

LINEAGE_ROOT="${MY_DIR}"/../../..

HELPER="${LINEAGE_ROOT}/vendor/lineage/build/tools/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

SECTION=
KANG=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in

    # Rename msm8953 to msm8996
    vendor/lib/hw/vulkan.msm8996.so | vendor/lib64/hw/vulkan.msm8996.so)
        sed -i "s|vulkan.msm8953.so|vulkan.msm8996.so|g" "${2}"
        ;;

    vendor/lib/hw/gatekeeper.msm8996.so | vendor/lib64/hw/gatekeeper.msm8996.so)
        sed -i "s|gatekeeper.msm8953.so|gatekeeper.msm8996.so|g" "${2}"
        ;;

    vendor/lib/hw/keystore.msm8996.so | vendor/lib64/hw/keystore.msm8996.so)
        sed -i "s|keystore.msm8953.so|keystore.msm8996.so|g" "${2}"
        ;;
    vendor/lib/hw/sound_trigger.primary.msm8996.so | vendor/lib64/hw/sound_trigger.primary.msm8996.so)
        sed -i "s|sound_trigger.primary.msm8953.so|sound_trigger.primary.msm8996.so|g" "${2}"
        ;;

    vendor/lib/hw/activity_recognition.msm8996.so | vendor/lib64/hw/activity_recognition.msm8996.so)
        sed -i "s|activity_recognition.msm8953.so|activity_recognition.msm8996.so|g" "${2}"
        ;;

    # Camera hax
    vendor/lib/libmmcamera2_stats_modules.so)
        sed -i "s|libgui.so|libfui.so|g" "${2}"
        sed -i "s|/data/misc/camera|/data/vendor/qcam|g" "${2}"
        patchelf --remove-needed libandroid.so "${2}"
        ;;

    vendor/lib/libmpbase.so)
        patchelf --remove-needed libandroid.so "${2}"
        ;;

   vendor/lib/libmm-qcamera.so | vendor/lib/libmmcamera2_cpp_module.so | vendor/lib/libmmcamera2_iface_modules.so | vendor/lib/libmmcamera2_imglib_modules.so | vendor/lib/libmmcamera2_mct.so | vendor/lib/libmmcamera2_pproc_modules.so | vendor/lib/libmmcamera2_stats_algorithm.so | vendor/lib/libmmcamera_dbg.so | vendor/lib/libmmcamera_hvx_grid_sum.so | vendor/lib/libmmcamera_hvx_zzHDR.so | vendor/lib/libmmcamera_imglib.so | vendor/lib/libmmcamera_isp_mesh_rolloff44.so | vendor/lib/libmmcamera_pdaf.so | vendor/lib/libmmcamera_pdafcamif.so | vendor/lib/libmmcamera_tintless_algo.so | vendor/lib/libmmcamera_tintless_bg_pca_algo.so | vendor/lib/libmmcamera_tuning.so)
        sed -i "s|/data/misc/camera|/data/vendor/qcam|g" "${2}"
        ;;

    vendor/lib/libmmcamera2_sensor_modules.so)
        sed -i "s|/system/etc/camera|/vendor/etc/camera|g" "${2}"
        sed -i "s|/data/misc/camera|/data/vendor/qcam|g" "${2}"
        ;;

    vendor/bin/mm-qcamera-daemon)
        sed -i "s|/data/vendor/camera/cam_socket%d|/data/vendor/qcam/camer_socket%d|g" "${2}"
        ;;

    esac
}

# Initialize the helper for common device
setup_vendor "${DEVICE_COMMON}" "${VENDOR}" "${LINEAGE_ROOT}" true "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" \
        "${KANG}" --section "${SECTION}"

if [ -s "${MY_DIR}/../${DEVICE}/proprietary-files.txt" ]; then
    # Reinitialize the helper for device
    source "${MY_DIR}/../${DEVICE}/extract-files.sh"
    setup_vendor "${DEVICE}" "${VENDOR}" "${LINEAGE_ROOT}" false "${CLEAN_VENDOR}"

    extract "${MY_DIR}/../${DEVICE}/proprietary-files.txt" "${SRC}" \
            "${KANG}" --section "${SECTION}"
fi

"${MY_DIR}/setup-makefiles.sh"
