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
    
    
#%% Downscale the file Size

from PIL import Image
import os
import PIL
import glob
input_path = r'C:\Users\smahmud\Desktop\MCS Dataset\images\jpg\NonDerecho'
#output_path = r'C:\Users\smahmud\Desktop\MCS Dataset\images\resize_NonDerecho'
images = [file for file in os.listdir(input_path) if file.endswith(('jpeg', 'png', 'jpg'))]

for image in images:
    img = Image.open(os.path.join(input_path,image))
   
    img.thumbnail((600,600))
    img.save(r'C:\Users\smahmud\Desktop\MCS Dataset\images\resize_NonDerecho\  resized_'+image, optimize=True, quality=40)
