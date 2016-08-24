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

saved_angle = -180

function saveAngle(angle)
    saved_angle=angle
end

function getAngle()
    return saved_angle
end


init()

srv=net.createServer(net.TCP)
srv:listen(80, function(conn)
    conn:on("receive", function(client, request)
        local code, method, path = require("connection").handle(client, request)
        collectgarbage()

        if method == "POST" and code == 200 then
            local motor = require("motor")
            if(path == "/close")then
                motor.turn_to(90)
            elseif(path == "/open")then
                motor.turn_to(0)
            elseif(path == "/tilt")then
                motor.turn_to(-90)
            elseif(path == "/tuneclose")then
                motor.turn(150, gpio.HIGH)
            elseif(path == "/tuneopen")then
                motor.turn(150, gpio.LOW)
            elseif(path == "/ms")then
                wifi.sleeptype(wifi.MODEM_SLEEP)
            elseif(path == "/ls")then
                wifi.sleeptype(wifi.LIGHT_SLEEP)
            elseif(path == "/ds")then
                wifi.sleeptype(node.dsleep(0))
            end
            collectgarbage()
        end
    end)
end)

