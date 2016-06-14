ENABLE = 2
DIR = 1
SLEEP = 7
HARD_ADC_LIMIT = 160 -- 3200 mA
SOFT_ADC_LIMIT = 120 -- 2400 mA
HARD_TIME = 150 * 1000 -- 150 ms

dofile("config.lua")

function init()
    wifi.setmode(wifi.STATION)
    wifi.sta.config(SSID, PASS)
    wifi.sleeptype(wifi.LIGHT_SLEEP)
    print(wifi.sta.getip())

    gpio.mode(ENABLE, gpio.OUTPUT)
    gpio.mode(DIR, gpio.OUTPUT)
    gpio.mode(SLEEP, gpio.OUTPUT)
    gpio.write(SLEEP, gpio.LOW)
end

function turn(duration, direction)
    gpio.write(SLEEP, gpio.HIGH)
    gpio.write(ENABLE, gpio.HIGH)
    gpio.write(DIR, direction)

    local start_time = tmr.now()
    local adc_stop = false
    print("start_time " .. start_time)
    repeat
        tmr.delay(50)
        delta = tmr.now() - start_time
        if delta < 0 then delta = delta + 2147483647 end;

        adc_value = adc.read(0)
        print("ADC " .. adc_value .. " delta " .. delta)

        if adc_value > HARD_ADC_LIMIT then
            print("adc stop")
            break
        end
        if adc_value > SOFT_ADC_LIMIT and delta > HARD_TIME then
            print("adc + delta stop")
            break
        end
    until delta > duration * 1000

    gpio.write(ENABLE, gpio.LOW)
    gpio.write(DIR, gpio.LOW)
    gpio.write(SLEEP, gpio.LOW)
end

init()

srv=net.createServer(net.TCP)
srv:listen(80, function(conn)
    conn:on("receive", function(client, request)
        local cmd = require("connection").handle(client, request)
        collectgarbage()
        if(cmd == "CLOSE")then
            turn(1800, gpio.HIGH)
        elseif(cmd == "OPEN")then
            turn(1400, gpio.LOW)
        elseif(cmd == "TUNECLOSE")then
            turn(150, gpio.HIGH)
        elseif(cmd == "TUNEOPEN")then
            turn(150, gpio.LOW)
        elseif(cmd == "MS")then
            wifi.sleeptype(wifi.MODEM_SLEEP)
        elseif(cmd == "LS")then
            wifi.sleeptype(wifi.LIGHT_SLEEP)
        elseif(cmd == "DS")then
            wifi.sleeptype(node.dsleep(0))
        end
    end)
end)

