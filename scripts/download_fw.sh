#!/usr/bin/env bash
#
# Copyright (C) 2025 Salvo Giangreco
# SPDX-License-Identifier: GPL-3.0-or-later
#

source "$SRC_DIR/scripts/utils/firmware_utils.sh" || return 1
source "$TOOLS_DIR/venv/bin/activate" || return 1

DOWNLOAD_FIRMWARE() {
    if [ "$#" -lt 4 ]; then
        echo -e "Usage: ${FUNCNAME[0]} <MODEL> <DOWNLOAD_DIRECTORY> <FIRMWARE_URL_1> <FIRMWARE_URL_2>"
        return 1
    fi

    local MODEL="$1"
    local DOWN_DIR="${2}/$MODEL"
    local URL1="$3"
    local URL2="$4"

    rm -rf "$DOWN_DIR"
    mkdir -p "$DOWN_DIR"

    echo -e "${YELLOW}  Samsung FW Downloader (Dual Link)   ${NC}"
    echo -e "MODEL: $MODEL"

    for i in 1 2; do
        local URL_VAR="URL$i"
        local URL="${!URL_VAR}"
        local OUTPUT_FILE="$DOWN_DIR/${MODEL}_part${i}.zip"

        if [ -z "$URL" ]; then
            echo -e "- ⛔️ FIRMWARE_URL_$i is empty. Skipping download."
            return 1
        fi

        echo -e "- 📥 Downloading firmware part $i via direct link..."
        wget --no-check-certificate --progress=bar:force "$URL" -O "$OUTPUT_FILE"

        if [ $? -ne 0 ] || [ ! -f "$OUTPUT_FILE" ]; then
            echo -e "- ⛔️ Download failed for part $i. Check URL or network."
            return 1
        fi

        # Handle .zip.md5 files
        if [[ "$URL" == *.md5 ]]; then
            echo -e "- 🔧 Detected .zip.md5 format for part $i. Removing MD5 suffix..."
            mv "$OUTPUT_FILE" "$DOWN_DIR/${MODEL}_part${i}.zip"
            OUTPUT_FILE="$DOWN_DIR/${MODEL}_part${i}.zip"
        fi

        local file_size
        file_size=$(du -m "$OUTPUT_FILE" | cut -f1)
        echo -e "- ✅ Firmware part $i downloaded successfully! Size: ${file_size} MB"
        echo -e "- Saved to: $OUTPUT_FILE"
    done
}

# Execute download using environment variables exported from workflow
if [ -n "$FW_URL_1" ] && [ -n "$FW_URL_2" ]; then
    DOWNLOAD_FIRMWARE "$MODEL" "$FW_DIR" "$FW_URL_1" "$FW_URL_2" || exit 1
else
    echo "- ⚠️ FW_URL_1 or FW_URL_2 not set. Skipping dual firmware download."
fi
