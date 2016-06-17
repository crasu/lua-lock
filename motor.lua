local M, module = {}, ...
local config = require("config")
local ENABLE = config.ENABLE_PIN
local DIR = config.DIR_PIN
local SLEEP = config.SLEEP_PIN
local HARD_ADC_LIMIT = 160 -- 3200 mA
local SOFT_ADC_LIMIT = 120 -- 2400 mA
local HARD_TIME = 150 * 1000 -- 150 ms

function M.init()
    package.loaded[module]=nil
    
    gpio.mode(ENABLE, gpio.OUTPUT)
    gpio.mode(DIR, gpio.OUTPUT)
    gpio.mode(SLEEP, gpio.OUTPUT)
    gpio.write(SLEEP, gpio.LOW)
end

function M.turn(duration, direction)
    package.loaded[module]=nil
    
    gpio.write(SLEEP, gpio.HIGH)
    gpio.write(ENABLE, gpio.HIGH)
    gpio.write(DIR, direction)

    local start_time = tmr.now()
    local adc_stop = false
    print("start_time " .. start_time)
    repeat
        tmr.delay(50)
        delta = bit.band(0x7fffffff, tmr.now() - start_time)

        adc_value = adc.read(0)
        print("ADC " .. adc_value .. " delta " .. delta)

        if adc_value > HARD_ADC_LIMIT then
            print("adc stop")
            break
        end
        if adc_value > SOFT_ADC_LIMIT and delta > M.HARD_TIME then
            print("adc + delta stop")
            break
        end
    until delta > duration * 1000

    gpio.write(ENABLE, gpio.LOW)
    gpio.write(DIR, gpio.LOW)
    gpio.write(SLEEP, gpio.LOW)
end

return M
