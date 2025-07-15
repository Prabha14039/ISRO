import rasterio
from rasterio.merge import merge
from rasterio.windows import from_bounds

# -----------------------------
# Input and Output Files
# -----------------------------
input_files = [
    "Tiles_Dataset/output/NAC_POLE_SOUTH_CM_AVG_P892S0450.TIF",
    "Tiles_Dataset/output/NAC_POLE_SOUTH_CM_AVG_P892S1350.TIF",
    "Tiles_Dataset/output/NAC_POLE_SOUTH_CM_AVG_P892S2250.TIF",
    "Tiles_Dataset/output/NAC_POLE_SOUTH_CM_AVG_P892S3150.TIF",
]

merged_output_path = "Tiles_Dataset/merged_pole_mosaic.tif"
clipped_output_path = "Tiles_Dataset/Malapart_Massif_mossaic.tif"

# -----------------------------
# A3GT Bounding Box (in meters)
# -----------------------------
min_x = -9703.71152840432
max_x =  11511.772138051236
min_y = -10826.943981692568
max_y =  9903.406892624425

# -----------------------------
# Merge input files into one
# -----------------------------
#src_files = [rasterio.open(f) for f in input_files]
#mosaic, mosaic_transform = merge(src_files)

# Save merged mosaic (optional but useful)
#merged_meta = src_files[0].meta.copy()
#merged_meta.update({
#    "height": mosaic.shape[1],
#    "width": mosaic.shape[2],
#    "transform": mosaic_transform
#})

#with rasterio.open(merged_output_path, "w", **merged_meta) as dest:
#    dest.write(mosaic)
#print(f"✅ Merged file saved to {merged_output_path}")

# -----------------------------
# Crop the exact A3GT bounding box
# -----------------------------
with rasterio.open(merged_output_path) as src:
    window = from_bounds(min_x, min_y, max_x, max_y, transform=src.transform)
    clipped_data = src.read(window=window)
    clipped_transform = src.window_transform(window)

    clipped_meta = src.meta.copy()
    clipped_meta.update({
        "height": window.height,
        "width": window.width,
        "transform": clipped_transform
    })

# -----------------------------
# Save cropped ROI
# -----------------------------
with rasterio.open(clipped_output_path, "w", **clipped_meta) as dst:
    dst.write(clipped_data)

print(f"✅ Clipped A3GT ROI saved to {clipped_output_path}")

