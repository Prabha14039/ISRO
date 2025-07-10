import rasterio
from rasterio.windows import from_bounds
import os
import math

def get_overlap_bounds(ds1, ds2):
    b1 = ds1.bounds
    b2 = ds2.bounds
    return (
        max(b1.left, b2.left),
        max(b1.bottom, b2.bottom),
        min(b1.right, b2.right),
        min(b1.top, b2.top)
    )

def tile_pair_by_geographic_extent(nac_path, sldem_path, out_dir, tile_width_m=256, tile_height_m=320, min_valid_ratio=0.9):
    os.makedirs(f"{out_dir}/nac", exist_ok=True)
    os.makedirs(f"{out_dir}/sldem", exist_ok=True)

    with rasterio.open(nac_path) as nac_ds, rasterio.open(sldem_path) as sldem_ds:
        left, bottom, right, top = get_overlap_bounds(nac_ds, sldem_ds)

        n_cols = math.floor((right - left) / tile_width_m)
        n_rows = math.floor((top - bottom) / tile_height_m)

        print(f"📐 Creating up to {n_rows * n_cols} geographic-aligned tile pairs...")

        tile_id = 0
        skipped_tiles = 0

        for row in range(n_rows):
            for col in range(n_cols):
                xmin = left + col * tile_width_m
                xmax = xmin + tile_width_m
                ymax = top - row * tile_height_m
                ymin = ymax - tile_height_m

                nac_window = from_bounds(xmin, ymin, xmax, ymax, transform=nac_ds.transform)
                nac_tile = nac_ds.read(1, window=nac_window, boundless=True, fill_value=0)

                sldem_window = from_bounds(xmin, ymin, xmax, ymax, transform=sldem_ds.transform)
                sldem_tile = sldem_ds.read(1, window=sldem_window, boundless=True, fill_value=-32768)

                # Calculate valid pixel ratios
                nac_valid_ratio = (nac_tile != 0).sum() / nac_tile.size
                sldem_valid_ratio = (sldem_tile != -32768).sum() / sldem_tile.size

                if nac_valid_ratio < min_valid_ratio or sldem_valid_ratio < min_valid_ratio:
                    skipped_tiles += 1
                    continue  # Skip tiles with insufficient valid data

                # Write NAC tile
                nac_meta = nac_ds.meta.copy()
                nac_meta.update({
                    "height": nac_tile.shape[0],
                    "width": nac_tile.shape[1],
                    "transform": rasterio.windows.transform(nac_window, nac_ds.transform)
                })
                nac_tile_path = f"{out_dir}/nac/nac_{tile_id:05d}.tif"
                with rasterio.open(nac_tile_path, "w", **nac_meta) as dst:
                    dst.write(nac_tile, 1)

                # Write SLDEM tile
                sldem_meta = sldem_ds.meta.copy()
                sldem_meta.update({
                    "height": sldem_tile.shape[0],
                    "width": sldem_tile.shape[1],
                    "transform": rasterio.windows.transform(sldem_window, sldem_ds.transform)
                })
                sldem_tile_path = f"{out_dir}/sldem/sldem_{tile_id:05d}.tif"
                with rasterio.open(sldem_tile_path, "w", **sldem_meta) as dst:
                    dst.write(sldem_tile, 1)

                tile_id += 1

        print(f"✅ Done: {tile_id} tile pairs saved.")
        print(f"❌ Skipped: {skipped_tiles} tile pairs due to insufficient valid data.")


