import cv2
import numpy as np

# lowerBound=np.array([33,80,40])
# upperBound=np.array([102,255,255])

lowerBound = np.array([0, 170, 90])
upperBound = np.array([378, 255, 255])

cam = cv2.VideoCapture('media_drive/clip-stablized.mp4')
kernelOpen = np.ones((5, 5))
kernelClose = np.ones((20, 20))

while(cam.isOpened()):
    ret, img = cam.read()
    img = cv2.resize(img, (680, 440))

    # convert BGR to HSV
    imgHSV = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

    # create the Mask
    mask = cv2.inRange(imgHSV, lowerBound, upperBound)

    # morphology
    maskOpen = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernelOpen)
    maskClose = cv2.morphologyEx(maskOpen, cv2.MORPH_CLOSE, kernelClose)

    maskFinal = maskClose
    conts, h = cv2.findContours(maskFinal.copy(), cv2.RETR_EXTERNAL,
                                cv2.CHAIN_APPROX_NONE)

    cv2.drawContours(img, conts, -1, (255, 0, 0), 3)
    for i in range(len(conts)):
        x, y, w, h = cv2.boundingRect(conts[i])
        cv2.rectangle(img, (x, y), (x+w, y+h), (0, 0, 255))
    cv2.imshow("maskClose", maskClose)
    cv2.imshow("cam", img)
    cv2.imshow("imgHSV", imgHSV)
    cv2.waitKey(10)
