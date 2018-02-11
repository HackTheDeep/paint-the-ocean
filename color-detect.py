import cv2
import numpy as np

lowerBound = np.array([0, 170, 90])
upperBound = np.array([378, 255, 255])

# cam = cv2.VideoCapture('1-batch-1_333.mp4')
# cam = cv2.VideoCapture('2-batch-334_527.mp4')
cam = cv2.VideoCapture('3-batch-528_769.mp4')

while(cam.isOpened()):
    ret, img = cam.read()
    img = cv2.resize(img, (340, 220))
    imgHSV = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    mask = cv2.inRange(imgHSV, lowerBound, upperBound)
    kernelOpen = np.ones((5, 5))
    kernelClose = np.ones((20, 20))
    maskOpen = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernelOpen)
    maskClose = cv2.morphologyEx(maskOpen, cv2.MORPH_CLOSE, kernelClose)

    maskFinal = maskClose
    conts, h = cv2.findContours(maskFinal.copy(), cv2.RETR_EXTERNAL,
                                cv2.CHAIN_APPROX_NONE)
    cv2.drawContours(img, conts, -1, (255, 0, 0), 3)

    cv2.imshow("maskClose", maskClose)
    cv2.imshow("maskOpen", maskOpen)

    # cv2.imshow('imgHSV', imgHSV)
    # cv2.imshow('img', img)
    # cv2.imshow('mask', mask)
    if cv2.waitKey(10) & 0xFF == ord('q'):
        break

cam.release()
cv2.destroyAllWindows()
