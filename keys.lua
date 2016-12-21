local M, module = {}, ...
local config = require("config")
local lock_state = false

function lock()
    if lock_state then 
        return false
    end
    
    lock_state = true
    local LOCK_TIME = 4000
    print("Keys locked ...")
    tmr.alarm(2, LOCK_TIME, tmr.ALARM_SINGLE, function() 
       print("Keys unlocked")
       lock_state = false
    end)

    return true
end

function M.init()
    package.loaded[module]=nil
    local OPEN = require("config").OPEN_PIN
    local CLOSE = require("config").CLOSE_PIN
    local TILT = require("config").TILT_PIN
    
    gpio.mode(OPEN, gpio.INT, gpio.PULLUP)
    gpio.mode(CLOSE, gpio.INT, gpio.PULLUP)
    gpio.mode(TILT, gpio.INT, gpio.PULLUP)

    function detect_spike(pin)
        tmr.delay(300)
        local level = gpio.read(pin)
        if not(level == 0) then
            print "spike detected"
        end

        return not(level == 0)
    end

    gpio.trig(OPEN, "down", function ()
        if not(lock()) then return end
        if detect_spike(OPEN) then return end
        
        print("open triggered")
        require("motor").turn_to(0)
    end)

    gpio.trig(CLOSE, "down", function ()
        if not(lock()) then return end
        if detect_spike(CLOSE) then return end
        
        print("close triggered")
        require("motor").turn_to(90)
    end)
    
    gpio.trig(TILT, "down", function ()
        if not(lock()) then return end
        if detect_spike(TILT) then return end

        print("tilt triggered")
        require("motor").turn_to(-90)
    end)
    
end

return M
