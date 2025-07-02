#!/bin/bash
set -euo pipefail

# Target download folder (one level up)
OUT_DIR="../img_folder"

# Create it if it doesn't exist
mkdir -p "$OUT_DIR"

# Read and download each URL
while IFS= read -r url; do
  [[ -z "$url" ]] && continue
  echo "Downloading: $url"
  wget --no-check-certificate -P "$OUT_DIR" "$url"
done < download.txt

