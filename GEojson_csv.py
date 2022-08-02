# -*- coding: utf-8 -*-
"""
Created on Mon Aug  1 14:22:55 2022

@author: smahmud
"""
#%% Panda Series approach

''' This approach works only for small geojson file. Make sure to use the another
 approach method  for the big geojson file (<2 GB)'''


import pandas as pd



#path = r"C:\Users\smahmud\Downloads\building Footprints"

df = pd.read_json(r"C:\Users\smahmud\Downloads\building Footprints\Texas.geojson")


# dataframe = []
# for f in  os.listdir(path):
#     if f.endswith(".geojson"):
#         dataframe.append(f)

# Splitting the Dictionary element in the features column
# for name in dataframe:
    

df_new = df.features.apply(pd.Series)

# # Splitting the Dictionary element in the Geometry column which will give us coordinates

df_geom = df_new['geometry'].apply(pd.Series)

# # Extracting the first coordinates from the tuple of the coordinates (more for simplicity)

df_coord = df_geom['coordinates']

su = []
for x in range(len(df_coord)):
    su.append((df_coord[x][0][0]))        

Cal_cord = pd.DataFrame(su) 

    

Cal_cord.columns = ['Longitude', 'Latitude']

Cal_cord.to_csv("Texas_Cord.csv") 


#%% Another approach method

''' this method should be use for big json/geojson file higher than 2 GB'''


import pandas as pd

# Reading the file

df = pd.read_json(r"C:\Users\smahmud\Downloads\building Footprints\Wyoming.geojson")

# Reading the feature column

df_new = df['features']

#Convert it to the dataframe

df2=pd.DataFrame(df_new)
# Extract the Specif key from the dictionary. 
# We are using this method instead of applyinf pd.Series which is not very
# Computationally efficient.

name = [d.get('geometry') for d in df2.features]

name1 = pd.DataFrame(name)

ss = name1['coordinates']

# Looping through the directory

su = []
for x in range(len(ss)):
    su.append((ss[x][0][0]))  


# Creating the dataframe
    
Cal_cord = pd.DataFrame(su) 



Cal_cord.columns = ['Longitude', 'Latitude']

Cal_cord.to_csv("Wyoming_Coord.csv") 