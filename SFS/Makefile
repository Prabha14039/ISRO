exe:=scripts
python:=/opt/homebrew/Caskroom/miniforge/base/envs/lunar_env/bin/python3
tif:=Dataset/tif
A3GT_ref:=$(tif)/reference/A3GT
massif_ref:=$(tif)/reference/M_massif
hillshade:=$(tif)/hillshade
dem:=ldem_80s_20m_scale.tif
ref:=$(A3GT_ref)/ref_blur.tif
mal_ref:=$(massif_ref)/ref_blur_mal_massif.tif
ref_hill:=$(hillshade)/A3GT.tif
massif_hill:=$(hillshade)/Massif.tif
cub:=Dataset/cub


.PHONY: start json img2cub hillshade clip visual clean

all: preprocess json clip

start:
	 $(python) $(exe)/download.py

preprocess:
	bash scripts/img2cub.sh --img_folder Dataset/img --cub_folder Dataset/cub --lola_cub $(cub)/ldem_80s_20m.cub

json:
	bash scripts/json.sh --cub_folder Dataset/cub --json_folder Dataset/json

clip:
	bash scripts/clipping.sh --scale_dem $(tif)/$(dem) --ref_dem $(tif)/ref.tif --blur_dem $(tif)/reference/ref_blur.tif --cord "-10999.986964673859 110999.90478880588 9999.980317101663 131999.86201203143"

visual:
	bash scripts/hillshade.sh --in Site23.tif  --out temp1.tif --azi 300 --ele 20 --fin new.tif
	rm -rf  temp1.tif
	bash scripts/hillshade.sh --in $(mal_ref) --out temp2.tif --azi 300 --ele 20 --fin $(massif_hill)

clean:
	@echo "🧹 Cleaning temporary files..."
	@rm -f default.profraw print.prt

