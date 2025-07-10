#!/bin/bash
set -e

LBL="DEM/LDEM_80S_20M.LBL"
CUB="dem_cub/ldem_80s_20m.cub"
SCALED="tiff/ldem_80s_20m_scale.tif"
REF="tiff/reference.tif"
BLUR="tiff/ref_blur.tif"
proj="+proj=stere +lat_0=-85.3643 +lon_0=31.2387 +R=1737400 +units=m +no_defs"

mkdir -p tiff

SCALE=$(grep -i SCALING_FACTOR "$LBL" | head -n1 | sed 's/[^0-9.]//g')
echo "ℹ️  Using SCALING_FACTOR=$SCALE"

echo "📈 Scaling DEM..."
image_calc -c "$SCALE * var_0" "$CUB" -o "$SCALED"

echo "📏 Resampling to 1m GSD..."
gdalwarp -overwrite -r cubicspline -tr 5 5 \
  -co COMPRESSION=LZW -co TILED=yes -co INTERLEAVE=BAND \
  -co BLOCKXSIZE=256 -co BLOCKYSIZE=256 \
  -t_srs "$proj"
  -te -7050.5 -10890.5 -1919.5 -5759.5 \
  "$SCALED" "$REF"

echo "💨 Blurring and cleaning..."
dem_mosaic --dem-blur-sigma 2 "$REF" -o "$BLUR"

