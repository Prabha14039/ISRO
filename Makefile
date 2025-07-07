# ======================
# DEM + NAC Processing Pipeline
# ======================

.PHONY: all help lola scale cubs json maps lists ba clean

# 🔁 Full pipeline
all: lola scale cubs json maps lists ba

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

cubs:
	bash scripts/img_to_cub.sh

json:
	bash scripts/generate_json.sh

maps:
	bash scripts/mapproject.sh

lists:
	bash scripts/generate_lists.sh

ba:
	bash scripts/run_parallel_ba.sh

# 🧹 Clean local temp artifacts
clean:
	@echo "🧹 Cleaning temporary files..."
	@rm -f default.profraw print.prt

