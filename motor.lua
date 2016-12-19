local M, module = {}, ...
local config = require("config")
local ENABLE = config.ENABLE_PIN
local DIR = config.DIR_PIN
local SLEEP = config.SLEEP_PIN
local HARD_ADC_LIMIT = 160 -- 3200 mA
local SOFT_ADC_LIMIT = 120 -- 2400 mA
local HARD_TIME = 150 * 1000 -- 150 ms
local MAX_DURATION = 3500 * 1000 -- 2000 ms

function M.init()
    package.loaded[module]=nil

    if adc.force_init_mode(adc.INIT_ADC)
    then
      node.restart()
      return 
    end
    
    gpio.mode(ENABLE, gpio.OUTPUT)
    gpio.mode(DIR, gpio.OUTPUT)
    gpio.mode(SLEEP, gpio.OUTPUT)
    gpio.write(SLEEP, gpio.LOW)  
    gpio.write(ENABLE, gpio.LOW)
    gpio.write(DIR, gpio.HIGH)   
end

function checkAngle(target_angle)
    local current_angle=require("adxl").angle()
    print("current angle " .. current_angle)
    if math.abs(target_angle - current_angle) < 6 then
        return false, false
    end

    return true, (target_angle - current_angle) > 0 -- returns: Enable, Direction
end

function set_direction(direction)
    if direction then 
        gpio.write(DIR, gpio.HIGH)
    else
        gpio.write(DIR, gpio.LOW)  
    end
end

function M.turn_to(angle)
    package.loaded[module]=nil
    
    gpio.write(SLEEP, gpio.HIGH)
    require("adxl").enable()
 
    local enable, direction = checkAngle(angle)
    if not(enable) then return end 
   
    gpio.write(ENABLE, gpio.HIGH)
    set_direction(direction)
     
    local start_time = tmr.now()
    print("start_time " .. start_time)
    tmr.alarm(0, 10, tmr.ALARM_AUTO, function ()
        local delta = bit.band(0x7ffffffe, tmr.now() - start_time)

        adc_value = adc.read(0)
        print("ADC " .. adc_value .. " delta " .. delta)

        local stop = false
        if adc_value > HARD_ADC_LIMIT then
            print("adc stop")
            stop = true
        end
        if adc_value > SOFT_ADC_LIMIT and delta > HARD_TIME then
            print("adc + delta stop")
            stop = true
        end
        if delta > MAX_DURATION then
            print("delta stop max duration")
            stop = true
        end

        enable, direction = checkAngle(angle)
        set_direction(direction)
        if not(enable) then
            print("target angle")
            stop = true
        end 
        
        if stop then
            gpio.write(ENABLE, gpio.LOW)
            gpio.write(DIR, gpio.HIGH)
            gpio.write(SLEEP, gpio.LOW)
            print("motor stopped")
            
            require("adxl").disable()

            tmr.unregister(0)
        end
    end)
end

function M.turn(duration, direction)
    package.loaded[module]=nil
    
    gpio.write(SLEEP, gpio.HIGH)
    gpio.write(ENABLE, gpio.HIGH)
    gpio.write(DIR, direction)

    local start_time = tmr.now()
    print("start_time " .. start_time)
    repeat
        tmr.delay(50)
        local delta = bit.band(0x7ffffffe, tmr.now() - start_time)

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
    gpio.write(DIR, gpio.HIGH)
    gpio.write(SLEEP, gpio.LOW)
end

return M
