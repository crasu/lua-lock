#!/bin/sh
nodemcu-uploader --baud 115200 --start_baud 9600 upload *.lua
nodemcu-uploader --baud 115200 --start_baud 9600 upload index.min.html
