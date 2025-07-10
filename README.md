# 📌 High-Resolution Lunar DEM Generation using CNN + Shape-from-Shading (SfS)

This project generates high-resolution lunar Digital Elevation Models (DEMs) using a hybrid approach combining a CNN-based prediction model with Shape-from-Shading (SfS) refinement. The workflow is tailored for mono NAC/OHRC images and coarse SLDEM input.

---

## 📁 Directory Structure

```
.
├── input_train/          # NAC + SLDEM tiles
├── processed/            # Normalized tiles
├── cnn_output/           # CNN-predicted DEMs
├── sfs_output/           # SfS-refined DEMs
├── scripts/              # Preprocessing and training scripts
├── models/               # Saved CNN models
├── visualization/        # DEM comparison and visual inspection
├── .gitignore
├── Makefile
├── README.md
```

---

## 🔗 Dataset

The dataset includes:

* Controlled NAC mosaics in Polar Stereographic projection (1 m/pixel)
* SLDEM or LOLA DEM (coarse input at 20 m/pixel)

👉 [Download example data](https://drive.google.com/drive/folders/1CChYeVDqc499VNybrn5w4GTy0H4qOjd5?usp=sharing)

---

## 🧐 Workflow Overview

### Step 1: Prepare Input DEMs and Imagery

* Download and convert SLDEM to ISIS format.
* Apply scale factor and convert to GeoTIFF.
* Acquire controlled NAC mosaics.
* Resample NAC to match DEM.
* Clean DEM for SfS.

**Script:** `scripts/prepare_inputs.sh`

---

### Step 2: NAC & SLDEM Tile Generation

* Generate aligned tiles and skip low-validity ones.

**Script:** `scripts/tile_by_geographic_extent.py`

---

### Step 3: Elevation Normalization

* Normalize DEM tiles to \[0, 1] range after zero-mean, unit-variance scaling.

**Script:** `scripts/normalize_tiles.py`

---

### Step 4: CNN-based DEM Prediction

* Predict refined DEM using a trained CNN.

**Script:** `scripts/train_model.py`

---

### Step 5: SfS Refinement

* Apply Shape-from-Shading to enhance predicted DEMs using illumination cues.

---

## 📈 Evaluation

* Compare SfS DEMs to reference LOLA or stereo DEMs
* Metrics: RMSE, elevation profile differences, terrain features

---

## 💡 Key Features

* Works with mono NAC/OHRC images
* Does not require stereo or altimetry input
* CNN learns terrain structure; SfS refines shape realism
* Supports lunar south polar regions
* Produces ≤2 m/pixel DEMs from mission-ready imagery

---

## 📂 All Bash Commands

```bash
bash scripts/prepare_inputs.sh
python scripts/tile_by_geographic_extent.py
python scripts/normalize_tiles.py
python scripts/train_model.py
```

