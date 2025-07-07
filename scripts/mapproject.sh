#!/bin/bash
set -e

CUB_FOLDER="cub_folder"
JSON_FOLDER="json_folder"
OUT_DIR="tiff/img2tif"
REF_DEM="tiff/reference.tif"

mkdir -p "$OUT_DIR"

for cub in "$CUB_FOLDER"/*.cub; do
    base=$(basename "$cub" .cub)
    json="$JSON_FOLDER/$base.json"
    out="$OUT_DIR/${base}_map.tif"
    echo "🗺️  Mapprojecting $cub → $out"
    mapproject -t csm "$REF_DEM" "$cub" "$json" "$out" --tr 1 --tile-size 1024
done

