import rasterio
import os
from itertools import combinations

def get_bounds(file):
    with rasterio.open(file) as src:
        return src.bounds

def boxes_overlap(bounds1, bounds2):
    return not (bounds1.right <= bounds2.left or
                bounds1.left >= bounds2.right or
                bounds1.top <= bounds2.bottom or
                bounds1.bottom >= bounds2.top)

# Set this to the folder where your .map.tif files are
MAP_DIR = "tiff/img2tif"

# List all .map.tif files
map_files = sorted([
    os.path.join(MAP_DIR, f)
    for f in os.listdir(MAP_DIR)
    if f.endswith(".map.tif")
])

# Load bounds for each file
bounds_dict = {f: get_bounds(f) for f in map_files}

# Compare all pairs
overlapping_pairs = []
for f1, f2 in combinations(map_files, 2):
    if boxes_overlap(bounds_dict[f1], bounds_dict[f2]):
        overlapping_pairs.append((os.path.basename(f1), os.path.basename(f2)))

# Output results
print("✅ Overlapping Pairs Found:\n")
for f1, f2 in overlapping_pairs:
    print(f"{f1}  <-->  {f2}")

# Optionally save to a file
with open("overlapping_pairs.txt", "w") as out:
    for f1, f2 in overlapping_pairs:
        out.write(f"{f1} {f2}\n")

