#!/bin/bash
set -e

# Default values
SCALED=""
REF=""
BLUR=""
CORD=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --scale_dem)
            SCALED="$2"
            shift 2
            ;;
        --ref_dem)
            REF="$2"
            shift 2
            ;;
        --blur_dem)
            BLUR="$2"
            shift 2
            ;;
        --cord)
            CORD="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 --scale_dem path --ref_dem path --blur_dem path --cord value"
            exit 0
            ;;
        *)
            echo "❌ Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate input
if [[ -z "$SCALED" || -z "$CORD" || -z "$REF" || -z "$BLUR" ]]; then
    echo "❗ Missing required arguments"
    echo "Usage: $0 --scale_dem path --ref_dem path --blur_dem path --cord value"
    exit 1
fi

mkdir -p Dataset/tif

echo "📏 Resampling to 1m GSD..."
gdalwarp -overwrite -r cubicspline -tr 1 1 \
  -co COMPRESSION=LZW -co TILED=yes -co INTERLEAVE=BAND \
  -co BLOCKXSIZE=256 -co BLOCKYSIZE=256 \
  -te $(echo $CORD) \
  "$SCALED" "$REF"

echo "💨 Blurring and cleaning..."
dem_mosaic --dem-blur-sigma 2 "$REF" -o "$BLUR"

