from gradient import get_edges
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
import matplotlib.gridspec as gridspec
import glob
import os
import cv2

def create_result(image, title):
    # Plot the result
    f, (ax1, ax2) = plt.subplots(1, 2, figsize=(24, 9))
    #f.tight_layout()
    ax1.axis('off')
    ax1.imshow(image)
    ax1.set_title('Original', fontsize=18)
    ax2.axis('off')
    ax2.imshow(result)
    ax2.set_title('Edges', fontsize=18)
    plt.savefig(title)


os.chdir('img/')
for filename in os.listdir(os.getcwd()):
    image = mpimg.imread(filename)
    result = get_edges(image, separate_channels=True)
    title = filename + ".jpg"
    create_result(image, title)
