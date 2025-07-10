#!/bin/bash
set -e

IMG_FOLDER="img_folder"
CUB_FOLDER="DTM_cub"
LOLA_CUB="dem_cub/ldem_80s_20m.cub"

mkdir -p "$CUB_FOLDER"

for img in "$IMG_FOLDER"/*.IMG; do
    base=$(basename "$img" .IMG)
    cub="$CUB_FOLDER/$base.cub"
    echo "🔄 Converting $img → $cub"
    lronac2isis from="$img" to="$cub"
    echo "🛰️  Running SPICEINIT for $cub"
    spiceinit from="$cub" shape=USER model="$LOLA_CUB" web=yes
done

