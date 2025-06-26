s := img_folder
d := cub_folder

images := $(wildcard $(s)/*.IMG)
cubes := $(patsubst $(s)/%.IMG, $(d)/%.cub, $(images))

all: $(cubes)

$(d)/%.cub:$(s)/%.IMG
	@echo "Converting $< to $@"
	@mkdir -p $(d)
	lronac2isis from=$< to=$@

clean:
	@echo "cleaning!!!"
	@rm -rf default.profraw print.prt
