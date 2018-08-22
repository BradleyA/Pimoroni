#!/usr/bin/env python
# 	ba-test-text.py  3.78.192  2018-08-21_22:24:06_CDT  https://github.com/BradleyA/pi-display  uadmin  six-rpi3b.cptx86.com 3.77  
# 	   start design and deveopment of scrollphathd/ #22 

import time
import signal

import scrollphathd
from scrollphathd.fonts import font3x5

print("""
Scroll pHAT HD: Hello World

Scrolls "Hello World" across the screen
in a 3x5 pixel condensed font.

Press Ctrl+C to exit!

""")

#Uncomment to rotate the text
scrollphathd.rotate(180)

#Set a more eye-friendly default brightness
scrollphathd.set_brightness(0.5)

scrollphathd.write_string(".|   3 CONTAINERS  0 ALERTS  0 WARNINGS  0 SECURITY UPDATES  0 UPDATES   ...   ...   ", x=0, y=1, font=font3x5, brightness=0.5)

while True:
    scrollphathd.show()
    scrollphathd.scroll()
    time.sleep(0.05)

