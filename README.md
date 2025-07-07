# Creating a DEM Using a Coarse DEM and NAC Images Enhanced with SfS

This project prepares a Digital Elevation Model (DEM) using coarse LOLA data and NAC images. The coarse DEM is refined using Shape-from-Shading (SfS).

---

## 📁 Directory Structure

```
.
├── DEM/
├── Stereopipeline/
├── ba/
├── bundle_para/
├── cub_folder/
├── dem_cub/
├── img_folder/
├── isisdata/
├── json_folder/
├── misc1/
├── preview/
├── run_full1/
├── scripts/
├── sfs_ref1/
├── tiff/
├── .gitignore
├── Makefile
├── README.md
├── main.py
```

---

## 🔗 Dataset

You can access the dataset used in this project from the following Google Drive folder:
👉 [Google Drive Dataset](https://drive.google.com/drive/folders/1CChYeVDqc499VNybrn5w4GTy0H4qOjd5?usp=sharing)

---

## 1. Download LOLA DEM (20 m/pixel)

```bash
wget http://imbrium.mit.edu/DATA/LOLA_GDR/POLAR/IMG/LDEM_80S_20M.IMG
wget http://imbrium.mit.edu/DATA/LOLA_GDR/POLAR/IMG/LDEM_80S_20M.LBL
```

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

## 5. Clean DEM (Blur Spikes, Fill Holes)

```bash
dem_mosaic --dem-blur-sigma 2 ref.tif -o ref_blur.tif
dem_mosaic --hole-fill ref_blur.tif -o ref_clean.tif
```

## 6. Select and Filter NAC Images

* **Download images:** Up to \~1,400 NAC .IMG files inside desired lon/lat bounds (Section 11.5).

* **Convert to ISIS/CSM:** `.IMG → .cub` (Section 11.7); prefer **CSM** camera models (Section 11.6).

* **Quick preview:** `mapproject` each image onto `ref_clean.tif` at low resolution (Section 11.7.4).

* **Automatic relevance test**

  ```bash
  dem_mosaic --block-max --block-size 10000 \
    --t_projwin -7050.5 -10890.5 -1919.5 -5759.5 \
    M*.map.lowres.tif -o tmp.tif | tee pixel_sum_list.txt
  ```

  * Positive pixel sums ⇒ image overlaps region of interest. Remove others.

* **Sort by illumination:**

  ```bash
  sfs --query *.cub   # prints Sun‑azimuth (°) per image
  ```

  * Order images so Sun azimuth changes gradually; avoids registration failures.
