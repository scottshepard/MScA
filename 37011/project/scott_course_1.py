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

    def take_pictures(self, left_speed, right_speed, n=1):
        for i in range(n):
            imageinx = datetime.now().strftime('%m%d%Y%H%M%S')
            imagename = self.save_path + 'image_{0}_{1}_{2}.jpeg'.format(imageinx, left_speed, right_speed)
            self.camera.capture(imagename)

class Robot:
    
    def __init__(self):
        self.robot = EasyGoPiGo3()
    
    def set_motor(self, turn_ratio, speed_factor):
        left_speed, right_speed = self.turn_ratio_to_speeds(turn_ratio, speed_factor)
        self.robot.set_motor_dps(self.robot.MOTOR_LEFT,  left_speed)
        self.robot.set_motor_dps(self.robot.MOTOR_RIGHT, right_speed)
    
    def turn_ratio_to_speeds(self, turn_ratio, speed_factor, max_speed=MAX_SPEED):
        if turn_ratio == 1:
            ls, rs =  1.0, 1.0
        elif turn_ratio < 1:
            ls, rs = turn_ratio, 1.0
        elif turn_ratio > 1:
            ls, rs = 1.0, 1.0/turn_ratio
        return ls*max_speed*speed_factor, rs*max_speed*speed_factor
            
    def stop(self):
        self.robot.stop()

robot = Robot()
camera = Camera(RESOLUTION, SAVE_PATH)

def step_01():
    robot.set_motor(1, 1)
    sleep(3)
    robot.stop()

def step_02():
    robot.set_motor(1.5, .6)
    sleep(2)
    robot.stop()
    
def step_03():
    robot.set_motor(1, .85)
    sleep(4)
    robot.stop()

def step_04():
    robot.set_motor(.5, 1)
    sleep(.8)
    robot.stop()

def step_05():
    robot.set_motor(1, 1)
    sleep(2)
    robot.stop()
    
def step_06():
    robot.set_motor(.5, .5)
    sleep(2)
    robot.stop()
    
def step_07():
    robot.set_motor(1, 1)
    sleep(2.6)
    robot.stop()
    
def step_08():
    robot.set_motor(.6, .5)
    sleep(1.8)
    robot.stop()
    
def step_09():
    robot.set_motor(1, 1)
    sleep(1.4)
    robot.stop()
    
def step_10():
    robot.set_motor(.6, .6)
    sleep(3)
    robot.stop()
    
def step_11():
    robot.set_motor(1, 1)
    sleep(3.5)
    robot.stop()

def run_course():
    step_01()
    step_02()
    step_03()
    step_04()
    step_05()
    step_06()
    step_07()
    step_08()
    step_09()
    step_10()
    step_11()
    robot.stop()
    
    
    
    
    
    
    
    




