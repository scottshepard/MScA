import picamera
from gopigo3 import FirmwareVersionError
from easygopigo3 import EasyGoPiGo3
from time import sleep
from datetime import datetime

MAX_FORCE = 5.0
MIN_SPEED = 100
MAX_SPEED = 300
SAVE_PATH = '/media/pi/PORTFOLIO/'
RESOLUTION = '320x240'

class Camera:

    def __init__(self, resolution, save_path):
        self.camera = picamera.PiCamera(resolution=resolution)
        self.save_path = save_path

    def take_pictures(self, left_speed, right_speed, i=1):
        for i in range(n):
            imageinx = datetime.now().strftime('%m%d%Y%H%M%S')
            imagename = self.save_path + 'image_{0}_{1}_{2}.jpeg'.format(imageinx, left_speed, right_speed)
            self.camera.capture(imagename)

robot = EasyGoPiGo3()
camera = Camera(RESOLUTION, SAVE_PATH)


robot.set_motor_dps(robot.MOTOR_RIGHT, 300)
robot.set_motor_dps(robot.MOTOR_LEFT,  300)
camera.take_pictures(300, 300)
time.sleep(2)
camera.take_pictures(300, 300)
robot.stop()

