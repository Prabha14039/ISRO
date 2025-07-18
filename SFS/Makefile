# Directories
IMG_DIR := Dataset/img
CUB_DIR := Dataset/cub
JSON_DIR := Dataset/json
LOLA_CUB := /Volumes/Windows/ISRO/SFS/Dataset/cub/ldem_80s_20m.cub
python := /opt/homebrew/Caskroom/miniforge/base/envs/lunar_env/bin/python3

# Get list of image base names (without path and extension)
SAMPLES := $(basename $(notdir $(wildcard $(IMG_DIR)/*.IMG)))

# Default target builds all JSONs
all: $(addprefix $(JSON_DIR)/, $(addsuffix .json, $(SAMPLES)))
cub: $(addprefix $(CUB_DIR)/, $(addsuffix .cub.done, $(SAMPLES)))
spicecub: $(addprefix $(CUB_DIR)/, $(addsuffix .spice.cub.done, $(SAMPLES)))

$(CUB_DIR)/%.cub.done: $(IMG_DIR)/%.IMG
	@mkdir -p $(CUB_DIR)
	@echo "Converting $< to $*.cub"
	lronac2isis from=$< to=$(CUB_DIR)/$*.cub
	@touch $@

# Rule: .cub → .spice.cub.done
$(CUB_DIR)/%.spice.cub.done: $(CUB_DIR)/%.cub.done
	@mkdir -p $(CUB_DIR)
	@echo "Creating spice.cub for $*"
	cp $(CUB_DIR)/$*.cub $(CUB_DIR)/$*.spice.cub
	spiceinit from=$(CUB_DIR)/$*.spice.cub shape=USER model=$(LOLA_CUB) web=yes
	@touch $@
	@rm -f $<


# Calibrate .cub → .cal.cub
$(CUB_DIR)/%.cal.cub.done: $(CUB_DIR)/%.cub
	@echo "Calibrating $<"
	lronaccal from=$< to=$(CUB_DIR)/$*.cal.cub
	@touch $@

# Echo .cal.cub → .cal.echo.cub
$(CUB_DIR)/%.cal.echo.cub: $(CUB_DIR)/%.cal.cub
	@echo "Echoing $<"
	lronacecho from=$< to=$@

# Generate JSON from .cal.echo.cub → .json
$(JSON_DIR)/%.json: $(CUB_DIR)/%.cal.echo.cub
	@mkdir -p $(JSON_DIR)
	@echo "Generating JSON from $<"
	isd_generate -o $@ $<
	@echo "Cleaning up intermediate files for $*"
	@rm -f $(CUB_DIR)/$*.cub
	@rm -f $(CUB_DIR)/$*.cal.cub

.PHONY: all cub spicecub

