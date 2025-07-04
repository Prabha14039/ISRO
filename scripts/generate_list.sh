#!/usr/bin/env bash
set -e  # Stop on first error

###--- USER PATHS ----------------------------------------------------------
CUB_DIR="cub_folder"                     # .cub files
CAMERA_DIR="json_folder"                 # *.adjusted_state.json
MAP_DIR="tiff/img2tif"                   # *_map.tif
MAP_DEM="tiff/ref.tif"                   # DEM used in mapprojection
OUT_DIR="bundle_para"                    # where list files go
mkdir -p "$OUT_DIR"
###-------------------------------------------------------------------------

# Temporary file that will hold "azimuth filename" pairs
TMP_LIST="$OUT_DIR/sorted_by_azimuth.txt"
> "$TMP_LIST"  # truncate

echo "🛰  Extracting SubSolarAzimuth from $CUB_DIR/*.cub …"

for cub in "$CUB_DIR"/*.cub; do
  base=$(basename "$cub" .cub)
  pvl="TEMP_${base}.pvl"

  echo "   ↳ $cub"
  if caminfo from="$cub" to="$pvl" > /dev/null 2>&1; then
    az=$(grep "SubSolarGroundAzimuth" "$pvl" | awk '{print $3}')
    if [[ -n "$az" ]]; then
      printf '%10.6f  %s\n' "$az" "$cub" >> "$TMP_LIST"
      echo "      ✅ SubSolarAzimuth: $az°"
    else
      echo "      ⚠️  No SubSolarAzimuth in $cub" >&2
    fi
    rm -f "$pvl"
  else
    echo "      ❌ caminfo failed on $cub" >&2
  fi
done

# Abort if nothing was written
if [[ ! -s "$TMP_LIST" ]]; then
  echo "❌ No SubSolarAzimuth values found. Exiting."
  exit 1
fi

echo -e "\n📑 Writing sorted final list files in $OUT_DIR …"
> "$OUT_DIR/image_list.txt"
> "$OUT_DIR/camera_list.txt"
> "$OUT_DIR/mapprojected_list.txt"

# Sort numerically and populate lists with live printing
echo "📈 Sorted SubSolarAzimuth values:"
sort -n "$TMP_LIST" | tee "$OUT_DIR/sorted_by_azimuth_sorted.txt" | while read -r az cub_path; do
  base=$(basename "$cub_path" .cub)

  printf "   → %10.6f  %s\n" "$az" "$base"

  echo "$cub_path"                        >> "$OUT_DIR/image_list.txt"
  echo "$CAMERA_DIR/${base}.json"        >> "$OUT_DIR/camera_list.txt"
  echo "$MAP_DIR/${base}_map.tif"        >> "$OUT_DIR/mapprojected_list.txt"
done

# Append the DEM to the mapprojected list
echo "$MAP_DEM" >> "$OUT_DIR/mapprojected_list.txt"

echo -e "\n✅ Done!"
echo "   → $(wc -l < "$OUT_DIR/image_list.txt") images"
echo "   → $(wc -l < "$OUT_DIR/camera_list.txt") cameras"
echo "   → $(($(wc -l < "$OUT_DIR/mapprojected_list.txt")-1)) mapprojected images (+DEM)"

