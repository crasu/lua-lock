# lua-lock

    ./anybaud /dev/ttyUSB0 74880
    cu --nostop -s 115200 -l /dev/ttyUSB0

## Flashing

Sometimes you have to use flash mode dio for nodemcu/non adafruit

    esptool.py  --port /dev/ttyUSB0 write_flash 0x00000 nodemcu-firmware/bin/nodemcu_integer_master_20160515-0600.bin 0x3fc000 ./nodemcu-firmware/sdk/esp_iot_sdk_v1.4.0/bin/esp_init_data_default.bin

## Minifying
    html-minifier --html5 --remove-optional-tags --collapse-whitespace --minify-css true --minify-js true index.html  > index.min.html

    upload.sh
