#!/usr/bin/python
import serial
import sys
import subprocess

#def on_message(client, userdata, msg):
#    print(msg.topic+" "+str(msg.payload))

#ser = serial.Serial("/dev/ttyACM0", 9600)
ser = serial.Serial("/dev/serial/by-id/usb-1a86_USB2.0-Serial-if00-port0", 9600)
while True:
    mess = ser.readline()
    print(mess)
