s := img_folder
d := cub_folder
a := json_folder
lola_img := DEM/LDEM_80S_20M.IMG
lola_lbl := DEM/LDEM_80S_20M.LBL

# Intermediate and final outputs
lola_cub := dem_cub/ldem_80s_20m.cub
lola_scaled := tif_files/ldem_80s_20m_scale.tif
ref_dem := tif_files/ref.tif
blurred_ref := tif_files/ref_blur.tif

IMG_FILES := $(wildcard $(s)/*.IMG)
CUBES     := $(patsubst $(s)/%.IMG, $(d)/%.cub, $(IMG_FILES))
JSONS     := $(patsubst $(d)/%.cub, $(a)/%.json, $(CUBES))

# Projection and extent parameters
proj := "+proj=stere +lat_0=-85.3643 +lon_0=31.2387 +R=1737400 +units=m +no_defs"
te := -te -7050.5 -10890.5 -1919.5 -5759.5

.PHONY: all clean cubes jsons lola_dem_convert

all: cubes jsons

cubes: $(CUBES)

jsons: $(JSONS)

# Rule to create .cub from .IMG
$(d)/%.cub: $(s)/%.IMG
	@mkdir -p $(d)
	@echo "🔄 Converting $< → $@"
	lronac2isis from=$< to=$@
	@echo "🛰️  Initializing SPICE..."
	spiceinit from=$@ web=yes

# Rule to create .json from .cub
$(a)/%.json: $(d)/%.cub
	@mkdir -p $(a)
	@echo "📝 Generating ISD: $< → $@"
	isd_generate -o $@ $<


# ===============================
# LOLA DEM Conversion Section
# ===============================

# Final target
lola_dem_convert: $(blurred_ref)

# Convert PDS LOLA IMG+LBL to ISIS cub
$(lola_cub): $(lola_lbl) $(lola_img)
	pds2isis from=$(lola_lbl) to=$(lola_cub)

# Automatically extract SCALING_FACTOR from .LBL
scale := $(shell grep -i SCALING_FACTOR $(lola_lbl) | head -n1 | sed 's/[^0-9.]//g')

$(lola_scaled): $(lola_cub)
	@echo "ℹ️  Extracted SCALING_FACTOR = $(scale) from $(lola_lbl)"
	image_calc -c "$(scale)*var_0" $(lola_cub) -o $(lola_scaled)

# Reproject and resample to 1m GSD, compressed and tiled
$(ref_dem): $(lola_scaled)
	gdalwarp -overwrite -r cubicspline -tr 1 1 \
	  -co COMPRESSION=LZW -co TILED=yes -co INTERLEAVE=BAND \
	  -co BLOCKXSIZE=256 -co BLOCKYSIZE=256 \
	  -t_srs $(proj) $(te) $(lola_scaled) $(ref_dem)

# Blur to remove spikes/artifacts
$(blurred_ref): $(ref_dem)
	dem_mosaic --dem-blur-sigma 2 $(ref_dem) -o $(blurred_ref)

clean:
	@echo "🧹 Cleaning!"
	@rm -rf $(d)/*.cub $(a)/*.json default.profraw print.prt

