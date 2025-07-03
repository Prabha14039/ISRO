# Creating a DEM Using a Coarse DEM and NAC Images Enhanced with SfS

This project prepares a Digital Elevation Model (DEM) using coarse LOLA data and NAC images. The coarse DEM is refined using Shape-from-Shading (SfS).

## 1. Download LOLA DEM (20 m/pixel)

```bash
wget http://imbrium.mit.edu/DATA/LOLA_GDR/POLAR/IMG/LDEM_80S_20M.IMG
wget http://imbrium.mit.edu/DATA/LOLA_GDR/POLAR/IMG/LDEM_80S_20M.LBL
````

## 2. Convert to ISIS Cube Format

```bash
pds2isis from=LDEM_80S_20M.LBL to=ldem_80s_20m.cub
```

## 3. Scale DEM Heights (as per .LBL)

```bash
image_calc -c "0.5 * var_0" ldem_80s_20m.cub -o ldem_80s_20m_scale.tif
```

## 4. Resample to 1 m/pixel

```bash
gdalwarp -overwrite -r cubicspline -tr 1 1 \
  -co COMPRESSION=LZW -co TILED=yes -co INTERLEAVE=BAND \
  -co BLOCKXSIZE=256 -co BLOCKYSIZE=256 \
  -te -7050.5 -10890.5 -1919.5 -5759.5 \
  ldem_80s_20m_scale.tif ref.tif
```

## 5. (Optional) Reproject to Polar Stereographic

```bash
proj="+proj=stere +lat_0=-85.3643 +lon_0=31.2387 +R=1737400 +units=m +no_defs"

gdalwarp -t_srs "$proj" -r cubicspline -tr 1 1 -overwrite \
  -co COMPRESSION=LZW -co TILED=yes \
  ldem_80s_20m_scale.tif ref.tif
```

## 6. Clean DEM (Blur Spikes, Fill Holes)

```bash
dem_mosaic --dem-blur-sigma 2 ref.tif -o ref_blur.tif
dem_mosaic --hole-fill ref_blur.tif -o ref_clean.tif
```

## Notes

* Match DEM resolution to image GSD (use `mapproject` to estimate).
* Higher-res LOLA DEMs (5 m) available at: [https://core2.gsfc.nasa.gov/PGDA/LOLA\_5mpp/](https://core2.gsfc.nasa.gov/PGDA/LOLA_5mpp/)
* Stereo DEMs can be blended with LOLA DEM using `dem_mosaic`.

> Final output `ref_clean.tif` is used as the initial DEM for SfS enhancement with NAC imagery.

