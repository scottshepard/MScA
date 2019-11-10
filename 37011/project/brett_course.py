import picamera
from gopigo3 import FirmwareVersionError
from easygopigo3 import EasyGoPiGo3
from time import sleep
from datetime import datetime

gopigo3_robot = EasyGoPiGo3()


MAX_FORCE = 5.0
MIN_SPEED = 100
MAX_SPEED = 300

camera = picamera.PiCamera(resolution='320x240')

i=2
gopigo3_robot.set_motor_dps(gopigo3_robot.MOTOR_RIGHT, 300)
gopigo3_robot.set_motor_dps(gopigo3_robot.MOTOR_LEFT, 300 )


for x in range(i):
    now = datetime.now()
    imageinx = datetime.timestamp(now)
    imagename = '/home/pi/Desktop/data/' + \
                "%03d_%03d_%03d" % (imageinx, 300,
                                  300) + '.png'

    camera.capture(imagename)

sleep(i)

### TURN 1

i=1
gopigo3_robot.set_motor_dps(gopigo3_robot.MOTOR_RIGHT, 200)
gopigo3_robot.set_motor_dps(gopigo3_robot.MOTOR_LEFT, 300 )


for x in range(i):
    now = datetime.now()
    imageinx = datetime.timestamp(now)
    imagename = '/home/pi/Desktop/data/' + \
                "%03d_%03d_%03d" % (imageinx, 300,
                                  200) + '.png'

    camera.capture(imagename)

sleep(i)


i=2
gopigo3_robot.set_motor_dps(gopigo3_robot.MOTOR_RIGHT, 300)
gopigo3_robot.set_motor_dps(gopigo3_robot.MOTOR_LEFT, 300 )


for x in range(i):
    now = datetime.now()
    imageinx = datetime.timestamp(now)
    imagename = '/home/pi/Desktop/data/' + \
                "%03d_%03d_%03d" % (imageinx, 300,
                                  300) + '.png'

    camera.capture(imagename)

sleep(i)

### TURN 2
i=1
gopigo3_robot.set_motor_dps(gopigo3_robot.MOTOR_RIGHT, 205)
gopigo3_robot.set_motor_dps(gopigo3_robot.MOTOR_LEFT, 300 )


for x in range(i):
    now = datetime.now()
    imageinx = datetime.timestamp(now)
    imagename = '/home/pi/Desktop/data/' + \
                "%03d_%03d_%03d" % (imageinx, 300,
                                  205) + '.png'

    camera.capture(imagename)

sleep(i)

### STRAIGHAWAY

#i=1
#gopigo3_robot.set_motor_dps(gopigo3_robot.MOTOR_RIGHT, 300)
#gopigo3_robot.set_motor_dps(gopigo3_robot.MOTOR_LEFT, 300 )


#for x in range(i):
#    now = datetime.now()
#    imageinx = datetime.timestamp(now)
#    imagename = '/home/pi/Desktop/data/' + \
#                "%03d_%03d_%03d" % (imageinx, 300,
#                                  300) + '.png'

#    camera.capture(imagename)

#sleep(i)

### TURN 3
i=1
gopigo3_robot.set_motor_dps(gopigo3_robot.MOTOR_RIGHT, 300)
gopigo3_robot.set_motor_dps(gopigo3_robot.MOTOR_LEFT, 210 )


for x in range(i):
    now = datetime.now()
    imageinx = datetime.timestamp(now)
    imagename = '/home/pi/Desktop/data/' + \
                "%03d_%03d_%03d" % (imageinx, 210,
                                  300) + '.png'

    camera.capture(imagename)

sleep(i)

### STRAIGHTAWAY
i=5
gopigo3_robot.set_motor_dps(gopigo3_robot.MOTOR_RIGHT, 300)
gopigo3_robot.set_motor_dps(gopigo3_robot.MOTOR_LEFT, 300 )


for x in range(i):
    now = datetime.now()
    imageinx = datetime.timestamp(now)
    imagename = '/home/pi/Desktop/data/' + \
                "%03d_%03d_%03d" % (imageinx, 300,
                                  300) + '.png'

    camera.capture(imagename)

sleep(i)

### TURN 4
i=3
gopigo3_robot.set_motor_dps(gopigo3_robot.MOTOR_RIGHT, 300)
gopigo3_robot.set_motor_dps(gopigo3_robot.MOTOR_LEFT, 250 )


for x in range(i):
    now = datetime.now()
    imageinx = datetime.timestamp(now)
    imagename = '/home/pi/Desktop/data/' + \
                "%03d_%03d_%03d" % (imageinx, 250,
                                  300) + '.png'

    camera.capture(imagename)

sleep(i)

i=3
gopigo3_robot.set_motor_dps(gopigo3_robot.MOTOR_RIGHT, 300)
gopigo3_robot.set_motor_dps(gopigo3_robot.MOTOR_LEFT, 250 )


for x in range(i):
    now = datetime.now()
    imageinx = datetime.timestamp(now)
    imagename = '/home/pi/Desktop/data/' + \
                "%03d_%03d_%03d" % (imageinx, 250,
                                  300) + '.png'

    camera.capture(imagename)

sleep(i)

### STRAIGHTAWAY
i=2
gopigo3_robot.set_motor_dps(gopigo3_robot.MOTOR_RIGHT, 300)
gopigo3_robot.set_motor_dps(gopigo3_robot.MOTOR_LEFT, 300 )


for x in range(i):
    now = datetime.now()
    imageinx = datetime.timestamp(now)
    imagename = '/home/pi/Desktop/data/' + \
                "%03d_%03d_%03d" % (imageinx, 300,
                                  300) + '.png'

    camera.capture(imagename)

sleep(i)

### TURN 5
i=1
gopigo3_robot.set_motor_dps(gopigo3_robot.MOTOR_RIGHT, 235)
gopigo3_robot.set_motor_dps(gopigo3_robot.MOTOR_LEFT, 300 )


for x in range(i):
    now = datetime.now()
    imageinx = datetime.timestamp(now)
    imagename = '/home/pi/Desktop/data/' + \
                "%03d_%03d_%03d" % (imageinx, 300,
                                  235) + '.png'

    camera.capture(imagename)

sleep(i)

### STRAIGHTAWAY
i=1
gopigo3_robot.set_motor_dps(gopigo3_robot.MOTOR_RIGHT, 300)
gopigo3_robot.set_motor_dps(gopigo3_robot.MOTOR_LEFT, 300 )


for x in range(i):
    now = datetime.now()
    imageinx = datetime.timestamp(now)
    imagename = '/home/pi/Desktop/data/' + \
                "%03d_%03d_%03d" % (imageinx, 300,
                                  300) + '.png'

    camera.capture(imagename)

sleep(1.5)


### TURN 6
i=1
gopigo3_robot.set_motor_dps(gopigo3_robot.MOTOR_RIGHT, 190)
gopigo3_robot.set_motor_dps(gopigo3_robot.MOTOR_LEFT, 300 )


for x in range(i):
    now = datetime.now()
    imageinx = datetime.timestamp(now)
    imagename = '/home/pi/Desktop/data/' + \
                "%03d_%03d_%03d" % (imageinx, 300,
                                  190) + '.png'

    camera.capture(imagename)

sleep(i)

### STRAIGHTAWAY
i=1
gopigo3_robot.set_motor_dps(gopigo3_robot.MOTOR_RIGHT, 300)
gopigo3_robot.set_motor_dps(gopigo3_robot.MOTOR_LEFT, 300 )


for x in range(i):
    now = datetime.now()
    imageinx = datetime.timestamp(now)
    imagename = '/home/pi/Desktop/data/' + \
                "%03d_%03d_%03d" % (imageinx, 300,
                                  300) + '.png'

    camera.capture(imagename)

sleep(i)

gopigo3_robot.stop()