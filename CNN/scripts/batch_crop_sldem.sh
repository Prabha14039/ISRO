#!/bin/bash

# Path to your resampled SLDEM
SLDEM="tiff/ldem_80s_20m_scale.tif"

# Output folder
mkdir -p sldem_proj

# Projection for the Moon's South Pole
proj="+proj=stere +lat_0=-85.3643 +lon_0=31.2387 +R=1737400 +units=m +no_defs"
RES=5

# Loop through all NAC DTM files
for NAC_DTM in DTM_tif/NAC_POLE_SOUTH_CM_085_*.TIF; do

    echo "📂 Processing $NAC_DTM..."

    # Extract base name (e.g., M12345678)
    BASENAME=$(basename "$NAC_DTM" .TIF)
    OUTPUT="sldem_proj/sldem_${BASENAME}.tif"

    # Get bounding box from NAC DTM
    bbox=$(gdalinfo "$NAC_DTM" | grep -E "Upper Left|Lower Right")

    xmin=$(echo "$bbox" | grep "Upper Left" | sed -E 's/.*\(\s*([0-9\.-]+),.*/\1/')
    ymax=$(echo "$bbox" | grep "Upper Left" | sed -E 's/.*,\s*([0-9\.-]+)\).*/\1/')
    xmax=$(echo "$bbox" | grep "Lower Right" | sed -E 's/.*\(\s*([0-9\.-]+),.*/\1/')
    ymin=$(echo "$bbox" | grep "Lower Right" | sed -E 's/.*,\s*([0-9\.-]+)\).*/\1/')

    echo "🧭 Bounding Box: xmin=$xmin ymin=$ymin xmax=$xmax ymax=$ymax"

    # Warp the SLDEM to match the NAC DTM
    gdalwarp -overwrite \
        -te $xmin $ymin $xmax $ymax \
        -tr $RES $RES \
        -r cubicspline \
        -co TILED=YES -co COMPRESS=LZW -co BLOCKXSIZE=256 -co BLOCKYSIZE=256 -co BIGTIFF=yes \
        "$SLDEM" "$OUTPUT"


    echo "✅ Saved cropped SLDEM as $OUTPUT"
    echo ""
done

echo "🎉 All done!"

