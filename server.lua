function init()
    local config = require("config")

    wifi.setmode(wifi.STATION)
    wifi.sta.config(config.SSID, config.PASS)

    tmr.alarm(1, 10*60*1000, tmr.ALARM_SINGLE, function()
        print("light sleep serial unstable ...")
        wifi.sleeptype(wifi.LIGHT_SLEEP)
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
        if(cmd == "close")then
            motor.turn_to(90)
        elseif(cmd == "open")then
            motor.turn_to(0)
        elseif(cmd == "tilt")then
            motor.turn_to(-90)
        elseif(cmd == "tuneclose")then
            motor.turn(150, gpio.HIGH)
        elseif(cmd == "tuneopen")then
            motor.turn(150, gpio.LOW)
        elseif(cmd == "ms")then
            wifi.sleeptype(wifi.MODEM_SLEEP)
        elseif(cmd == "ls")then
            wifi.sleeptype(wifi.LIGHT_SLEEP)
        elseif(cmd == "ds")then
            wifi.sleeptype(node.dsleep(0))
        end
        collectgarbage()
    end)
end)

