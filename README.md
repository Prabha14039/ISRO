## 🌓 **Malapert Massif High-Resolution DEM Generation – Brief Overview**

### 🔹 **1. Region Selection**

* Malapert Massif was selected as a candidate landing site for **Artemis III**.
* A **4×4 km area** was defined around the nominal landing site to match the **2 km EVA radius**.

---

### 🔹 **2. Base DEM Preparation**

* Used **5 mpp LOLA LDEM** as the base elevation model.
* Resampled the data to **1 mpp** for higher resolution terrain processing.

---

### 🔹 **3. Controlled NAC Mosaic Usage**

* A **pre-existing controlled NAC mosaic** (Henriksen et al. 2023) of the Malapert region was used.
* It provided **accurate geolocation** and was used to **align individual NAC images**.

---

### 🔹 **4. NAC Image Download & Alignment**

* Despite having the mosaic, raw **NAC images were downloaded** for SfS.
* These images retain **original lighting and shadow details** needed for photometric modeling.
* Each NAC image was **aligned to the mosaic** for geographic accuracy.

---

### 🔹 **5. Tiling for Processing**

* The 4000×4000 pixel (4×4 km) region was split into **64 tiles** (8×8 grid), each 500×500 pixels.
* This made processing manageable and allowed parallel or per-tile computation.

---

### 🔹 **6. Shape-from-Shading (SfS) Application**

* **4 to 25 NAC images per tile** were selected based on coverage and lighting.
* SfS computed detailed elevation by analyzing **brightness differences** across images.
* This resulted in a **refined DEM** with high spatial detail (craters, roughness, slopes).

---

### 🔹 **7. Post-Processing & Slope Analysis**

* The refined DEM revealed:

  * Slope patterns near the ridgeline (10°–15° increasing to 20°–25°).
  * Surface hazards like craters and steep slopes.
* Useful for **EVA planning** and **HLS (Human Landing System)** testing.

---

### 🔹 **8. Gap Filling & Limitations**

* 6 out of 64 tiles failed SfS due to poor image data or alignment issues.
* Those tiles were **filled using original LOLA DEM**, introducing some artifacts.
* Noted limitation: **SfS doesn't work in permanently shadowed regions (PSRs)**, but LOLA does.

---

## ✅ **In Summary:**

> The process used LOLA as the base, a controlled NAC mosaic for alignment, raw NAC images for photometric detail, and SfS to generate a high-resolution DEM over a 4×4 km area — supporting safe landing and EVA planning for Artemis III.
