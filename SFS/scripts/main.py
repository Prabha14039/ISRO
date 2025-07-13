from pyproj import Proj

proj_str = "+proj=stere +lat_0=-85.964 +lon_0=357.681 +R=1737400 +units=m +no_defs"
proj = Proj(proj_str)

# Corrected bounding box: positive east longitudes
corners_lonlat = [
    (356.72848, -86.02928),  # Lower-Left
    (358.60300, -85.89764),  # Upper-Right
]

min_x, min_y = proj(*corners_lonlat[0])
max_x, max_y = proj(*corners_lonlat[1])

print(min_x, min_y, max_x, max_y)

