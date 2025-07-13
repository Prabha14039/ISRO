import os
import json
import requests
from bs4 import BeautifulSoup
from tqdm import tqdm

# 1. Load GeoJSON
geojson_path = "Dataset/2km_EVA.geojson"
with open(geojson_path, "r") as f:
    geojson_data = json.load(f)

# 2. Create output folder
output_folder = "Dataset/img"
os.makedirs(output_folder, exist_ok=True)

# 3. Process each feature
for feature in geojson_data["features"]:
    props = feature.get("properties", {})
    view_url = props.get("Url")
    image_label = props.get("Image")
    subsol_lon = props.get("SubSol Lon", "N/A")  # Log Sub-solar Longitude

    if not view_url:
        continue

    print(f"\n🔎 Image: {image_label}")
    print(f"🌞 Sub-solar Longitude: {subsol_lon}")
    print(f"🔗 View URL: {view_url}")

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

                # Download with progress bar
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
                print(f"✅ Downloaded {filename}")
                break
        else:
            print(f"❌ No EDR .IMG found on page: {view_url}")

    except Exception as e:
        print(f"⚠️ Error accessing {view_url}: {e}")

