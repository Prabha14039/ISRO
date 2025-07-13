# 📌 High-Resolution Lunar DEM Generation using CNN + Shape-from-Shading (SfS)
---

## 🛰️ Lunar DEM Enhancement Pipeline

This project aims to improve the accuracy of lunar DEMs (Digital Elevation Models) by fusing high-resolution NAC DTMs with coarse-resolution SLDEM using deep learning and refining results through Shape-from-Shading (SfS).

---

### 📂 Input Data

* **High-resolution NAC stereo-derived DEMs** (5 meters/pixel)
* **Coarse-resolution SLDEM** (20 meters/pixel, 80°S coverage)

---

### 🔄 Pipeline Overview

#### 1. ✅ Convert Input DEMs

* Convert `.IMG` files to ISIS `.cub` format using `lronac2isis`.
* Scale elevation values using the scaling factor in `.LBL` files.

#### 2. ✅ NAC DTM Selection (South Pole)

* Select controlled NAC DTMs covering the desired region at 1 m/pixel.
* Only use DTMs in **Lunar South Polar Stereographic** projection.

#### 3. ✅ Spatial Cropping and Tiling

* Crop SLDEM to match the NAC DTM spatial extent.
* Split both into tiles of **256×320 pixels**.

#### 4. ✅ Preprocessing

* Normalize NAC DEM elevations:

  * Zero-mean, unit-variance
  * Subtract minimum elevation
  * Scale to `[0, 1]`

#### 5. ✅ Dataset Preparation

* Select:

  * 27,000 training tiles
  * 3,000 validation tiles
* Apply **data augmentation**:

  * Random horizontal/vertical flips with 50% probability

---

### 🧠 Deep Learning Model

#### 🔹 Inputs:

* (LDEM tile).tif
* (NAC DTM tile).tif

#### 🔹 Encoders:

* **NAC → ResNet50**
* **SLDEM → 5 conv blocks**

#### 🔹 Fusion Strategy:

* Concatenate encoder features for joint decoding.

#### 🔹 Decoder:

* 4 up-projection blocks with skip connections for feature reconstruction.

#### 🔹 Output:

* 1-channel predicted DEM (CNN-derived DEM)

---

### 🛠 Post-Processing

* Apply **Shape-from-Shading (SfS)** using:

  * Predicted CNN-derived DEM
  * Original NAC images

---

### 🎯 Final Output

* **Improved-accuracy DEM**

---

## 🗂 Directory Structure (Recommended)

```bash
project/
├── data/
│   ├── NAC/                # Raw .IMG files
│   ├── SLDEM/              # Low-res SLDEM
│   └── labels/             # Processed DEMs or masks
├── scripts/
│   ├── download.py
│   ├── convert_to_cub.sh
│   └── preprocess.py
├── models/
│   └── unet_model.py
├── train/
│   └── train.py
├── inference/
│   └── sfs_refinement.py
└── README.md
```

---

## ⚙️ Dependencies

* [ISIS3](https://isis.astrogeology.usgs.gov/)
* `shapely`, `rasterio`, `opencv`, `torch`, `tqdm`, etc.

Install via:

```bash
pip install -r requirements.txt
```

---

## 🚀 Training Command

```bash
python train/train.py \
  --input_nac nac_tiles/ \
  --input_sldem sldem_tiles/ \
  --epochs 50 \
  --batch_size 32
```

---

## 📌 Notes

* All DEMs must be aligned to a **common projection**.
* Elevation values must be normalized for stable training.
* Post-SfS improvement can recover high-frequency terrain details.

---
