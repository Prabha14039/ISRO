#!/bin/bash
set -e

# Default values
IMG_FOLDER=""
CUB_FOLDER=""
LOLA_CUB=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --img_folder)
            IMG_FOLDER="$2"
            shift 2
            ;;
        --cub_folder)
            CUB_FOLDER="$2"
            shift 2
            ;;
        --lola_cub)
            LOLA_CUB="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 --img_folder path --cub_folder path --lola_cub path"
            exit 0
            ;;
        *)
            echo "❌ Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate input
if [[ -z "$IMG_FOLDER" || -z "$CUB_FOLDER" || -z "$LOLA_CUB" ]]; then
    echo "❗ Missing required arguments"
    echo "Usage: $0 --img_folder path --cub_folder path --lola_cub path"
    exit 1
fi

mkdir -p "$CUB_FOLDER"

# Loop over .IMG files
for img in "$IMG_FOLDER"/*.IMG; do
    base=$(basename "$img" .IMG)
    cub="$CUB_FOLDER/$base.cub"
    echo "🔄 Converting $img → $cub"
    lronac2isis from="$img" to="$cub"
    echo "🛰️  Running SPICEINIT for $cub"
    spiceinit from="$cub" shape=USER model="$LOLA_CUB" web=yes
done

