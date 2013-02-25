import Image
import matplotlib.pyplot as plt
import numpy as np

from damascene import damascene


image = Image.open('../damascene/polynesia.ppm')
data = np.array(image)
borders, textons, orientations = damascene(data, device_num=0)

plt.matshow(borders)
plt.matshow(textons)
plt.show()
