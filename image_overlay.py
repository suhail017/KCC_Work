# -*- coding: utf-8 -*-
"""
Created on Tue Sep 13 09:31:57 2022

@author: smahmud
"""

from matplotlib import pyplot as plt
import geopandas as gpd
import pandas as pd
from shapely.geometry import Point
from PIL import Image


plt.figure(figsize=(10, 10), dpi=300)
figure = plt.gcf()
figure.set_size_inches(8, 6)
#plt.rcParams["figure.figsize"] = [7.00, 3.50]
#plt.rcParams["figure.autolayout"] = True
path = r"C:\Users\smahmud\Desktop\MCS Dataset\july05.bmp"
file = Image.open(path)
filename = path.split('\\')[-1]
filename = filename.split('.')[0]
plt.imshow(file)
file.save(f"{filename}.jpg")

#%% Reading the Lat and lon

df = pd.read_csv(r"C:\Users\smahmud\july05.csv")

long = df.Lon

lat = df.Lat

geometry = [Point(xy) for xy in zip(long,lat)]


im = plt.imread(r"C:\Users\smahmud\Desktop\MCS Dataset\july05.bmp")

wardlink = r"C:\Users\smahmud\Downloads\geopandas-tutorial-master\data\usa-states-census-2014.shp"

ward = gpd.read_file(wardlink, bbox=None, mask=None, rows=None)
geo_df = gpd.GeoDataFrame(geometry = geometry)

ward.crs = {'init':"epsg:3395"}
geo_df.crs = {'init':"epsg:3395"}

# plot the polygon
#ax = ward.plot(alpha=0.35, color='#d66058', zorder=1)
# plot the boundary only (without fill), just uncomment
#ax = gpd.GeoSeries(ward.to_crs(epsg=3857)['geometry'].unary_union).boundary.plot(ax=ax, alpha=0.5, color="#ed2518",zorder=2)
#ax = gpd.GeoSeries(ward['geometry'].unary_union).boundary.plot(ax=ax, alpha=0.5, color="#ed2518",zorder=2)

# plot the marker
#ax = geo_df.plot(ax = ax, markersize = 20, color = 'red',marker = '*',label = 'Delhi', zorder=3)
plt.figure(figsize=(10, 10), dpi=300)
basemap = geo_df.plot(ax=ward.plot(figsize=(15, 8)), marker='o', color='red', markersize=100);
basemap = basemap.get_figure()
basemap.savefig(f'basmap_{filename}.jpg')
#ax=ward.plot(figsize=(15, 8))
#ax.add_image(im)
#plt.imshow(im)

# ctx.add_basemap(ax, crs=geo_df.crs.to_string(), source=ctx.providers.OpenStreetMap.Mapnik)
# plt.show()


#%% Combining the shape file and the radar imge

import cv2
from PIL import Image
import numpy as np

#background = cv2.imread(r"C:\Users\smahmud\Desktop\MCS Dataset\Figure 2022-09-13 112908.png")
#background = Image.open(f"{filename}.jpg")
background = cv2.imread(f"{filename}.jpg")
background = cv2.resize(background,(1080,576))
#background = np.array(background)

#background = background[:-1]
#overlay = Image.open(f'basmap_{filename}.jpg')
overlay = cv2.imread(f'basmap_{filename}.jpg')

#overlay = np.array(overlay)

# Nimg = background.resize((220,180))   # image resizing

# Nimg2 = overlay.resize((220,180))

added_image = cv2.addWeighted(background,1.9,overlay,1,0)
plt.imshow(added_image)
# new_img = cv2.imwrite('combined.png', added_image)
# new_img.show()