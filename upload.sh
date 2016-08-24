#!/bin/sh
sleep 1
nodemcu-uploader --baud 9600 --start_baud 9600 file remove init.lua
nodemcu-uploader --baud 9600 --start_baud 9600 node restart
sleep 1
nodemcu-uploader --baud 115200 --start_baud 9600 upload -c server.lua connection.lua adxl.lua motor.lua config.lua
nodemcu-uploader --baud 115200 --start_baud 9600 upload *.lua
html-minifier --html5 --remove-optional-tags --collapse-whitespace --minify-css true --minify-js true index.html  > index.min.html
nodemcu-uploader --baud 9600 --start_baud 9600 upload index.min.html
nodemcu-uploader --baud 9600 --start_baud 9600 node restart
