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

    local i=1
    for URL in "$URL1" "$URL2"; do
        if [ -z "$URL" ]; then
            echo -e "- ⛔️ FIRMWARE_URL_$i is empty. Skipping download."
            return 1
        fi

        # Extract exact filename from URL, strip query params
        local FILENAME
        FILENAME="$(basename "${URL%%\?*}")"
        local OUTPUT_FILE="$DOWN_DIR/$FILENAME"

        echo -e "- 📥 Downloading firmware link $i via direct link..."
        wget --no-check-certificate --progress=bar:force "$URL" -O "$OUTPUT_FILE"

        if [ $? -ne 0 ] || [ ! -f "$OUTPUT_FILE" ]; then
            echo -e "- ⛔️ Download failed for link $i. Check URL or network."
            return 1
        fi

        local file_size
        file_size=$(du -m "$OUTPUT_FILE" | cut -f1)
        echo -e "- ✅ Firmware link $i downloaded successfully! Size: ${file_size} MB"
        echo -e "- Saved to: $OUTPUT_FILE"

        ((i++))
    done
}

# Execute download using environment variables exported from workflow
if [ -n "$FW_URL_1" ] && [ -n "$FW_URL_2" ]; then
    DOWNLOAD_FIRMWARE "$MODEL" "$FW_DIR" "$FW_URL_1" "$FW_URL_2" || exit 1
else
    echo "- ⚠️ FW_URL_1 or FW_URL_2 not set. Skipping dual firmware download."
fi
