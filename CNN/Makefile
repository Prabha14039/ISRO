# ======================
#	Path/Variables
# ======================

LIBTORCH=/Volumes/Windows/ISRO/CNN/libtorch/
python_lun=/opt/homebrew/Caskroom/miniforge/base/envs/lunar_env/bin/python3
python_isis=/opt/homebrew/Caskroom/miniforge/base/envs/isis/bin/python3


# ======================
# DEM + NAC Processing Pipeline
# ======================

.PHONY: all help encoders decoders fusion train inference main

# 🔁 Full pipeline
all: encoders decoders fusion train inference main

# 📘 Help menu
help:
	@echo ""
	@echo "🛠️  Short Make Targets:"
	@echo "  make all     ➤ Run the full DEM processing pipeline"
	@echo "  make lola    ➤ Convert LOLA IMG+LBL to .cub"
	@echo "  make scale   ➤ Scale, resample, and blur the DEM"
	@echo "  make cubs    ➤ Convert NAC .IMG to .cub and initialize SPICE"
	@echo "  make json    ➤ Generate ISD .json files from .cub"
	@echo "  make maps    ➤ Mapproject each .cub file to GeoTIFF"
	@echo "  make lists   ➤ Generate image/camera/map lists for bundle adjustment"
	@echo "  make ba      ➤ Run parallel bundle adjustment"
	@echo "  make clean   ➤ Clean temporary logs and intermediate files"
	@echo ""

# 🎯 Individual stages
lola:
	bash scripts/convert_lola_dem.sh

scale:
	bash scripts/scale_resample_blur.sh

box:
	bash scripts/batch_crop_sldem.sh

# 🧹 Clean local temp artifacts
clean:
	@echo "🧹 Cleaning temporary files..."
	@rm -f default.profraw print.prt

cpp: #Todolist
	@echo "Moving to build Directory"
	@cd build && cmake -DCMAKE_PREFIX_PATH=$(LIBTORCH) .. && cmake --build . --config Release

encoders:
	@$(python_isis) src/encoder.py

fusion:
	@$(python_isis) src/fusion.py

decoders:
	@$(python_isis) src/decoder.py

train:
	@$(python_isis) src/trainning.py

inference:
	@$(python_isis) src/inference.py

main:
	@$(python_isis) src/main.py
