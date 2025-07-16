from pyproj import Proj

proj_str_Mal_massif = "+proj=stere +lat_0=-90 +lat_ts=-90 +lon_0=0 +R=1737400 +units=m +no_defs"
proj = Proj(proj_str_Mal_massif)

corners_longlat_MapartMassif = [
    (354.34052, -86.32279),  # Lower-Left
    (4.33231,  -85.63656),   # Upper-Right
]

min_x, min_y = proj(*corners_longlat_MapartMassif[0])
max_x, max_y = proj(*corners_longlat_MapartMassif[1])
print("Malapart_Massif")
print(min_x, min_y, max_x, max_y)
