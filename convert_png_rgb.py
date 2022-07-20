# -*- coding: utf-8 -*-
"""
Created on Wed Jul 20 10:59:47 2022

@author: smahmud
"""
#%% Convert to png to RGB 3 channel


from PIL import Image
import numpy as np
import os


path = r"C:\Users\smahmud\Downloads\NonMCS" # Declaring the destination folder

# Lisiting all the image files inside the folder

for filename in os.listdir(path):
    
    img = Image.open(os.path.join(path,filename))
    
    rgb_image = np.asarray(img.convert('RGB'));
    
    im = Image.fromarray(rgb_image)
    
    im.save(f"{path}\{filename.split('.')[0]}.jpg") 
    
    
