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
	bash scripts/clipping.sh --scale_dem Dataset/tif/ldem_80s_20m_scale.tif --ref_dem Dataset/tif/ref_mal_massif.tif --blur_dem Dataset/tif/ref_blur_mal_massif.tif --cord "-9703.71152840432 -10826.943981692568 11511.772138051236 9903.406892624425"

clean:
	@echo "🧹 Cleaning temporary files..."
	@rm -f default.profraw print.prt
