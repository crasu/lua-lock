function init()
    local config = require("config")
    local sleephours = 4
    wifi.setmode(wifi.STATION)
    wifi.sta.config(config.SSID, config.PASS)

    tmr.alarm(1, 10*60*1000, tmr.ALARM_SINGLE, function()
        print("light sleep serial unstable ...")
        wifi.sleeptype(wifi.LIGHT_SLEEP)
    end)

    tmr.alarm(2, 3600*1000, tmr.ALARM_AUTO, function()
        sleephours = sleephours - 1

        if sleephours < 1 then
            print("Going to a deep sleep ...")
            wifi.sleeptype(node.dsleep(0))                 
        end
    end)
    
    print(wifi.sta.getip())

    require("motor").init()
    require("keys").init()
end

init()

srv=net.createServer(net.TCP)
srv:listen(80, function(conn)
    conn:on("receive", function(client, request)
        local cmd = require("connection").handle(client, request)
        collectgarbage()
        local motor = require("motor")
        if(cmd == "CLOSE")then
            motor.turn_to(90)
        elseif(cmd == "OPEN")then
            motor.turn_to(0)
        elseif(cmd == "TILT")then
            motor.turn_to(-90)
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
        collectgarbage()
    end)
end)

