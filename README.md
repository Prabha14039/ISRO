---

# 🌓 Filter Mapprojected TIFFs Using `dem_mosaic`

This guide explains how to use `dem_mosaic` from the [Ames Stereo Pipeline](https://stereopipeline.readthedocs.io/) to filter out mapprojected TIFF files (`*.tif`) that **do not overlap** a specified region of interest (ROI) — e.g., for Shape-from-Shading (SfS) processing over lunar polar regions.

---

## 📂 Input

- A folder of mapprojected **TIFF** images (e.g., from `mapproject`)
- A defined **ROI** in projected coordinates (e.g., for the lunar south pole)
- [ASP](https://github.com/NeoGeographyToolkit/StereoPipeline) installed (command: `dem_mosaic`)

---

## 🔍 Goal

Identify and keep only the TIFF images that:
- Contribute valid data to a specified **ROI**
- Can later be used for SfS or DEM mosaicking

---

## 🧭 Steps

### 1. Place All `.tif` Files in One Folder

Example:
```

project/
├── tif/
│   ├── M1234567890RE.tif
│   ├── M1234567890LE.tif
│   └── ...

````

Navigate to the folder:
```bash
cd project/tif/
````

---

### 2. Run `dem_mosaic` in Filtering Mode

Use `--block-max` with a large `--block-size` to process each TIFF as a block.

#### 📌 Syntax:

```bash
dem_mosaic \
  --block-max \
  --block-size 10000 \
  --threads 1 \
  --t_projwin <xmin> <ymax> <xmax> <ymin> \
  *.tif -o dummy.tif | tee pixel_sum_list.txt
```

#### 📍 Example:

```bash
dem_mosaic \
  --block-max \
  --block-size 10000 \
  --threads 1 \
  --t_projwin -7050.5 -10890.5 -1919.5 -5759.5 \
  *.tif -o dummy.tif | tee pixel_sum_list.txt
```

* This does **not create a real mosaic**
* It prints each TIFF’s **pixel sum** inside the ROI

---

### 3. Extract Relevant TIFFs

Filter TIFFs that contribute any valid pixels:

```bash
grep -E '\.tif' pixel_sum_list.txt | awk '$NF != 0 {print $1}' > valid_tiffs.txt
```

This creates a file `valid_tiffs.txt` like:

```
M1234567890RE.tif
M1234567890LE.tif
...
```

---

### 4. (Optional) Move or Use Only Relevant TIFFs

You can copy or use the valid TIFFs:

```bash
mkdir ../filtered
xargs -a valid_tiffs.txt -I{}
```

