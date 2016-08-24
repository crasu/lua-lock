#!/bin/sh
nodemcu-uploader --baud 9600 --start_baud 9600 upload *.lua
html-minifier --html5 --remove-optional-tags --collapse-whitespace --minify-css true --minify-js true index.html  > index.min.html
nodemcu-uploader --baud 9600 --start_baud 9600 upload index.min.html
