#!/bin/bash
set -e

CUB_FOLDER="cub_folder"
JSON_FOLDER="json_folder"

mkdir -p "$JSON_FOLDER"

for cub in "$CUB_FOLDER"/*.cub; do
    base=$(basename "$cub" .cub)
    json="$JSON_FOLDER/$base.json"
    echo "📝 Generating ISD for $cub → $json"
    isd_generate -o "$json" "$cub"
done

