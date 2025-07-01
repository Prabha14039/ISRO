s := img_folder
d := cub_folder

images := $(wildcard $(s)/*.IMG)
cubes := $(patsubst $(s)/%.IMG, $(d)/%.cub, $(images))

all: sfs

ba: $(cubes)
	bundle_adjust $(d)/M139939938LE.cub $(d)/M139946735RE.cub --num-iterations 100 -o ba/run

stereo: ba
		parallel_stereo                           \
		--left-image-crop-win 0 7998 2728 2696  \
		--right-image-crop-win 0 9377 2733 2505 \
		--stereo-algorithm asp_mgm              \
		--subpixel-mode 9                       \
		--bundle-adjust-prefix ba/run           \
		$(d)/M139939938LE.cub $(d)/M139946735RE.cub                \
		run_full1/run

sfs: stereo
	sfs -i run_full1/run-crop-DEM.tif       \
		$(d)/M139939938LE.cub                         \
		--use-approx-camera-models            \
		--crop-input-images                   \
		--reflectance-type 1                  \
		--smoothness-weight 0.08              \
		--initial-dem-constraint-weight 0.001 \
		--max-iterations 10                   \
		-o sfs_ref1/run

$(d)/%.cub:$(s)/%.IMG
	@echo "Converting $< to $@"
	@mkdir -p $(d)
	@lronac2sis from=$< to=$@
	@echo "Using spice kerneals to fetch the info of cub files and inserting them into the files"
	@spiceinit from=$@ web=yes
	@isd_generate $@

download:
	wget --no-check-certificate -nc -c -i first_10.txt -P img_folder -o download_log.txt


clean:
	@echo "cleaning!!!"
	@rm -rf default.profraw print.prt
