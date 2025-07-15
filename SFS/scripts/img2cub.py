import sys
from pathlib import Path
import subprocess

def run(cmd):
    print(f"▶️ {cmd}")
    subprocess.run(cmd, shell=True, check=True)

img_Path = Path(sys.argv[1])
out_Path = Path(sys.argv[2])
dem_Path = Path(sys.argv[3])

base = img_Path.stem
cub_folder=out_Path.parent
cub = cub_folder / f"{base}.cub"
cal = cub_folder / f"{base}.cal.cub"

run(f"lronac2isis from={img_Path} to={cub}")
run(f"spiceinit from={cub} shape=USER model={dem_Path} web=yes")
run(f"lronaccal from={cub} to={cal}")
run(f"lronacecho from={cal} to={out_Path}")

cub.unlink(missing_ok=True)
cal.unlink(missing_ok=True)

