import picamera 
from gopigo3 import FirmwareVersionError
from easygopigo3 import EasyGoPiGo3
from time import sleep
from datetime import datetime
import cv2
import tensorflow as tf
import keras
from PIL import Image
import numpy as np


gopigo3_robot = EasyGoPiGo3()


MAX_FORCE = 5.0
MIN_SPEED = 100
MAX_SPEED = 300

camera = picamera.PiCamera(resolution='200x150')

def my_imread(image_path):
    image = cv2.imread(image_path)
    image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    return image

def img_preprocess(image):
    height, _, _ = image.shape
    image = image[int(height/2):,:,:]  # remove top half of the image, as it is not relevant for lane following
    image = cv2.cvtColor(image, cv2.COLOR_RGB2YUV)  # Nvidia model said it is best to use YUV color space
    image = cv2.GaussianBlur(image, (3,3), 0)
    image = cv2.resize(image, (200,66)) # input image size (200,66) Nvidia model
    image = image / 255 # normalizing
    return image

model = tf.keras.models.load_model('/home/pi/Desktop/data/lane_navigation_final.h5')

def compute_steering_angle(frame):
    preprocessed = img_preprocess(frame)
    X = np.asarray([preprocessed])
    steering_angle = model.predict(X)[0]
    return steering_angle

#camera.start_preview()
sleep(2)
for i in range(43):
    camera.capture("test.png")#, use_video_port=True)
    frame = my_imread("test.png")
    angle = compute_steering_angle(frame)
    print(angle)
    if angle <= 100:
        left = int(angle / 100 * 300)
        right = 300
    else:
        left = 300
        right = int(1/(angle / 100) * 300)

    print(left)
    print(right)
    gopigo3_robot.set_motor_dps(gopigo3_robot.MOTOR_RIGHT, right)
    gopigo3_robot.set_motor_dps(gopigo3_robot.MOTOR_LEFT, left )
    sleep(.3)

gopigo3_robot.stop()