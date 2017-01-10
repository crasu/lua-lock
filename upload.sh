#!/bin/sh
sleep 1
nodemcu-uploader --baud 115200 file remove init.lua
nodemcu-uploader --baud 115200 node restart
sleep 1
nodemcu-uploader --baud 115200 upload -c server.lua connection.lua adxl.lua motor.lua config.lua keys.lua
nodemcu-uploader --baud 115200 upload *.lua
html-minifier --html5 --remove-optional-tags --collapse-whitespace --minify-css true --minify-js true index.html  > index.min.html || cp index.html index.min.html
nodemcu-uploader --baud 115200 upload index.min.html
nodemcu-uploader --baud 115200 node restart
