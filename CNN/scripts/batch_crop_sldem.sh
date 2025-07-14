#!/bin/bash

# Path to your resampled SLDEM
SLDEM="Tiles_Dataset/ldem_80s_20m_scale.tif"

# Projection for the Moon's South Pole
RES=5

# Loop through all NAC DTM files
for NAC_DTM in Tiles_Dataset/NAC_POLE_SOUTH_CM_AVG_*.TIF; do

    echo "📂 Processing $NAC_DTM..."

    # Extract base name (e.g., M12345678)
    BASENAME=$(basename "$NAC_DTM" .TIF)
    OUTPUT="Tiles_Dataset/sldem_${BASENAME}.tif"

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

