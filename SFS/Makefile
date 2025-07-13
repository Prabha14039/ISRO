exe:=scripts
python:=/opt/homebrew/Caskroom/miniforge/base/envs/lunar_env/bin/python3

.PHONY: start

all: img2cub json

start:
	 $(python) $(exe)/download.py

img2cub:
	bash scripts/img2cub.sh --img_folder Dataset/img --cub_folder Dataset/cub --lola_cub cub/ldem_80s_20m.cub

json:
	bash scripts/json.sh --cub_folder Dataset/cub --json_folder Dataset/json
