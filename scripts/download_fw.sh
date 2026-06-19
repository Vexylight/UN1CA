#!/usr/bin/env bash
#
# Copyright (C) 2025 Salvo Giangreco
# SPDX-License-Identifier: GPL-3.0-or-later
#

source "$SRC_DIR/scripts/utils/firmware_utils.sh" || return 1
source "$TOOLS_DIR/venv/bin/activate" || return 1

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <FIRMWARE_URL_1> <FIRMWARE_URL_2>"
    exit 1
fi

download_single() {
    local URL="$1"
    local LABEL="$2"

    if [ -z "$URL" ]; then
        echo "- ⚠️ $LABEL URL is empty. Skipping."
        return 0
    fi

    wget --content-disposition \
         --no-check-certificate \
         --progress=bar:force:noscroll \
         "$URL" 2>&1

    if [ $? -ne 0 ]; then
        echo "- ⛔️ Download failed for $LABEL."
        return 1
    fi

    local FILENAME
    FILENAME=$(ls -1t | head -1)

    if [ -z "$FILENAME" ] || [ ! -f "$FILENAME" ]; then
        echo "- ⛔️ No file found after download for $LABEL."
        return 1
    fi

    echo "${LABEL}_FILENAME=$FILENAME" >> "${GITHUB_ENV:-/dev/null}"
    echo "✅ $LABEL Downloaded: $FILENAME ($(du -sh "$FILENAME" | cut -f1))"
}

download_single "$1" "FW1" || exit 1
download_single "$2" "FW2" || exit 1
