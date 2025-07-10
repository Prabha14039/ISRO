import rasterio
from rasterio.windows import from_bounds
import os
import math
import argparse

def get_overlap_bounds(ds1, ds2):
    b1 = ds1.bounds
    b2 = ds2.bounds
    return (
        max(b1.left, b2.left),
        max(b1.bottom, b2.bottom),
        min(b1.right, b2.right),
        min(b1.top, b2.top)
    )

def tile_pair_by_geographic_extent(nac_path, sldem_path, out_dir, tile_width_m=256, tile_height_m=320, min_valid_ratio=0.9, max_tiles=None):
    os.makedirs(f"{out_dir}/nac", exist_ok=True)
    os.makedirs(f"{out_dir}/sldem", exist_ok=True)

    with rasterio.open(nac_path) as nac_ds, rasterio.open(sldem_path) as sldem_ds:
        left, bottom, right, top = get_overlap_bounds(nac_ds, sldem_ds)

        n_cols = math.floor((right - left) / tile_width_m)
        n_rows = math.floor((top - bottom) / tile_height_m)

        print(f"📐 Maximum possible tile pairs: {n_rows * n_cols}")

        tile_id = 0
        skipped_tiles = 0

        for row in range(n_rows):
            for col in range(n_cols):
                if max_tiles is not None and tile_id >= max_tiles:
                    print(f"🛑 Reached max_tiles = {max_tiles}. Stopping early.")
                    break

                xmin = left + col * tile_width_m
                xmax = xmin + tile_width_m
                ymax = top - row * tile_height_m
                ymin = ymax - tile_height_m

                nac_window = from_bounds(xmin, ymin, xmax, ymax, transform=nac_ds.transform)
                nac_tile = nac_ds.read(1, window=nac_window, boundless=True, fill_value=0)

                sldem_window = from_bounds(xmin, ymin, xmax, ymax, transform=sldem_ds.transform)
                sldem_tile = sldem_ds.read(1, window=sldem_window, boundless=True, fill_value=-32768)

                # Check valid pixel ratios
                nac_valid_ratio = (nac_tile != 0).sum() / nac_tile.size
                sldem_valid_ratio = (sldem_tile != -32768).sum() / sldem_tile.size

                if nac_valid_ratio < min_valid_ratio or sldem_valid_ratio < min_valid_ratio:
                    skipped_tiles += 1
                    continue

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
        print(f"❌ Skipped: {skipped_tiles} tile pairs due to low valid data.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--nac", required=True, help="Path to NAC image")
    parser.add_argument("--sldem", required=True, help="Path to SLDEM image")
    parser.add_argument("--out_dir", required=True, help="Output directory for tiles")
    parser.add_argument("--tile_width", type=int, default=256, help="Tile width in meters")
    parser.add_argument("--tile_height", type=int, default=320, help="Tile height in meters")
    parser.add_argument("--min_valid_ratio", type=float, default=0.1, help="Minimum valid data ratio per tile")
    parser.add_argument("--max_tiles", type=int, default=None, help="Maximum number of tile pairs to generate")
    args = parser.parse_args()

    tile_pair_by_geographic_extent(
        nac_path=args.nac,
        sldem_path=args.sldem,
        out_dir=args.out_dir,
        tile_width_m=args.tile_width,
        tile_height_m=args.tile_height,
        min_valid_ratio=args.min_valid_ratio,
        max_tiles=args.max_tiles
    )

