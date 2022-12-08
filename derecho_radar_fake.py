import os

import cv2
from matplotlib import pyplot as plt


background = (cv2.imread(
    r"C:\Users\smahmud\source\repos\fakederecho\fakederecho\SimpleDerechoWithNoiseMethod2_2.png"))
background = cv2.cvtColor(background, cv2.COLOR_BGR2RGB)
#background = cv2.resize(background, (1080, 576))
plt.imshow(background)
overlay = cv2.imread(
    r"C:\Users\smahmud\Downloads\max_n0r_0z0z_2010060172.jpg", cv2.COLOR_BGR2RGB)
overlay = cv2.cvtColor(overlay, cv2.COLOR_BGR2RGB)
added_image = cv2.addWeighted(background, 0.4, overlay, 0.9, 0)
plt.axis('off')
plt.imshow(added_image)
plt.savefig('pict.png', bbox_inches='tight', pad_inches=0)

# plt.savefig(rf'{dir}/validate_{Date}.jpg')
