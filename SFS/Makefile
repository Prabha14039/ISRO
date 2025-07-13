exe:=scripts
python:=/opt/homebrew/Caskroom/miniforge/base/envs/lunar_env/bin/python3

.PHONY: start json

all: img2cub json

start:
	 $(python) $(exe)/download.py

img2cub:
	bash scripts/img2cub.sh --img_folder Dataset/img --cub_folder Dataset/cub --lola_cub cub/ldem_80s_20m.cub

json:
	bash scripts/json.sh --cub_folder Dataset/cub --json_folder Dataset/json

clip:
	bash scripts/clipping.sh --scale_dem Dataset/tif/ldem_80s_20m_scale.tif --ref_dem Dataset/tif/ref.tif --blur_dem Dataset/tif/ref_blur.tif --cord "-2000.0023603072427 -1996.0929794951319 1999.9984217298127 1996.2060531710554"

clean:
	@echo "🧹 Cleaning temporary files..."
	@rm -f default.profraw print.prt
