local M, module = {}, ...
M.ENABLE = 2
M.DIR = 1
M.SLEEP = 7
M.HARD_ADC_LIMIT = 160 -- 3200 mA
M.SOFT_ADC_LIMIT = 120 -- 2400 mA
M.HARD_TIME = 150 * 1000 -- 150 ms

function M.init()
    package.loaded[module]=nil
    
    gpio.mode(M.ENABLE, gpio.OUTPUT)
    gpio.mode(M.DIR, gpio.OUTPUT)
    gpio.mode(M.SLEEP, gpio.OUTPUT)
    gpio.write(M.SLEEP, gpio.LOW)
end

function M.turn(duration, direction)
    package.loaded[module]=nil
    
    gpio.write(M.SLEEP, gpio.HIGH)
    gpio.write(M.ENABLE, gpio.HIGH)
    gpio.write(M.DIR, direction)

    local start_time = tmr.now()
    local adc_stop = false
    print("start_time " .. start_time)
    repeat
        tmr.delay(50)
        delta = tmr.now() - start_time
        if delta < 0 then delta = delta + 2147483647 end;

        adc_value = adc.read(0)
        print("ADC " .. adc_value .. " delta " .. delta)

        if adc_value > M.HARD_ADC_LIMIT then
            print("adc stop")
            break
        end
        if adc_value > M.SOFT_ADC_LIMIT and delta > M.HARD_TIME then
            print("adc + delta stop")
            break
        end
    until delta > duration * 1000

    gpio.write(M.ENABLE, gpio.LOW)
    gpio.write(M.DIR, gpio.LOW)
    gpio.write(M.SLEEP, gpio.LOW)
end

return M