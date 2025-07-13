import os
import json
import requests
from shapely.geometry import shape, Polygon
from bs4 import BeautifulSoup
from tqdm import tqdm

# 1. Define your Region of Interest (ROI) polygon
roi_coords = [[
    [-4.76364169, -85.63394425],
    [4.33231398, -85.63655542],
    [5.14788482, -86.32588928],
    [-5.65948184, -86.32278684],
    [-4.76364169, -85.63394425]
]]
roi_polygon = Polygon(roi_coords[0])

# 2. Load GeoJSON
geojson_path = "Dataset/images.geojson"
with open(geojson_path, "r") as f:
    geojson_data = json.load(f)

# 3. Create output folder
output_folder = "Dataset/img"
os.makedirs(output_folder, exist_ok=True)

# 4. Process each feature
for feature in geojson_data["features"]:
    try:
        img_geom = shape(feature["geometry"])
        if not img_geom.intersects(roi_polygon):
            continue
    except Exception as e:
        print(f"⚠️ Geometry error: {e}")
        continue

    view_url = feature.get("properties", {}).get("Url")
    if not view_url:
        continue

    print(f"🔎 Intersecting image: {view_url}")
    try:
        response = requests.get(view_url, timeout=30)
        soup = BeautifulSoup(response.text, "html.parser")

        for link in soup.find_all("a"):
            href = link.get("href", "")
            if href.endswith(".IMG") and "EDR" in href:
                full_url = "https:" + href if href.startswith("//") else href
                filename = os.path.basename(full_url)
                out_path = os.path.join(output_folder, filename)

                if os.path.exists(out_path):
                    print(f"✅ Skipping {filename} (already exists)")
                    break

                # Fetch with progress
                with requests.get(full_url, stream=True) as file_response:
                    file_response.raise_for_status()
                    total = int(file_response.headers.get('content-length', 0))
                    with open(out_path, "wb") as f, tqdm(
                        total=total,
                        unit='B',
                        unit_scale=True,
                        unit_divisor=1024,
                        desc=filename
                    ) as bar:
                        for chunk in file_response.iter_content(chunk_size=1048576):  # 1 MB
                            f.write(chunk)
                            bar.update(len(chunk))
                break
        else:
            print(f"❌ No EDR .IMG found for {view_url}")

    except Exception as e:
        print(f"⚠️ Failed to download from {view_url}: {e}")

