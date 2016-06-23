function init()
    local config = require("config")
    wifi.setmode(wifi.STATION)
    wifi.sta.config(config.SSID, config.PASS)
    wifi.sleeptype(wifi.LIGHT_SLEEP)
    print(wifi.sta.getip())

    require("motor").init()
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
        collectgarbage()
    end)
end)

