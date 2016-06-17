

function init()
    local config = require("config")
    wifi.setmode(wifi.STATION)
    wifi.sta.config(config.SSID, config.PASS)
    wifi.sleeptype(wifi.LIGHT_SLEEP)
    print(wifi.sta.getip())

    require("motor").init()
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
        local motor = require("motor")
        if(cmd == "CLOSE")then
            motor.turn(1800, gpio.HIGH)
        elseif(cmd == "OPEN")then
            motor.turn(1400, gpio.LOW)
        elseif(cmd == "TUNECLOSE")then
            motor.turn(150, gpio.HIGH)
        elseif(cmd == "TUNEOPEN")then
            motor.turn(150, gpio.LOW)
        elseif(cmd == "MS")then
            wifi.sleeptype(wifi.MODEM_SLEEP)
        elseif(cmd == "LS")then
            wifi.sleeptype(wifi.LIGHT_SLEEP)
        elseif(cmd == "DS")then
            wifi.sleeptype(node.dsleep(0))
        end
    end)
end)

