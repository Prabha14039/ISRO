from pyproj import Proj

proj_str = "+proj=stere +lat_0=-85.964 +lon_0=357.681 +R=1737400 +units=m +no_defs"
proj_str_Mal_massif = "+proj=stere +lat_0=-85.97967 +lon_0=359.33633 +R=1737400 +units=m +no_defs"
proj = Proj(proj_str_Mal_massif)
Proje = Proj(proj_str)


# Corrected bounding box: positive east longitudes
corners_lonlat = [
    (353.26630662865, -86.903150594366),    # Upper-Right
    (2.6674004059205, -84.090533655566),    # Lower-Left
]

corners_longlat_MapartMassif = [
    (354.34052, -86.32279),  # Lower-Left
    (4.33231,  -85.63656),   # Upper-Right
]

min_x_1, min_y_1 = Proje(*corners_lonlat[0])
max_x_1, max_y_1 = Proje(*corners_lonlat[1])
min_x, min_y = proj(*corners_longlat_MapartMassif[0])
max_x, max_y = proj(*corners_longlat_MapartMassif[1])
print("Malapart_Massif")
print(min_x, min_y, max_x, max_y)
print("A3GT")
print(min_x_1, min_y_1, max_x_1, max_y_1)
