local M, module = {}, ...

id=0
sda=7 
scl=6 
dev_addr=0x53 

function M.enable()
    --package.loaded[module]=nil
    
    i2c.setup(id,sda,scl,i2c.SLOW)
    
    i2c.start(id)
    i2c.address(id, dev_addr,i2c.TRANSMITTER)
    
    i2c.write(id,0x2D)
    i2c.write(id,0x00) 
    i2c.stop(id)
    
    i2c.start(id)
    i2c.address(id, dev_addr,i2c.TRANSMITTER)
    i2c.write(id,0x31)
    i2c.write(id,0x0B) 
    i2c.stop(id)
    
    i2c.start(id)
    i2c.address(id, dev_addr,i2c.TRANSMITTER)
    i2c.write(id,0x2C)
    i2c.write(id,0x0A)
    i2c.stop(id)
    
    i2c.start(id)
    i2c.address(id, dev_addr,i2c.TRANSMITTER)
    i2c.write(id,0x2D)
    i2c.write(id,0x08) 
    i2c.stop(id)
end

function M.disable()  
    package.loaded[module]=nil
      
    i2c.start(id)
    i2c.address(id, dev_addr,i2c.TRANSMITTER)
    
    i2c.write(id,0x2D)
    i2c.write(id,0x00) 
    i2c.stop(id)
end

-- user defined function: read from reg_addr content of dev_addr
function read_reg(reg_addr)
    i2c.start(id)
    i2c.address(id, dev_addr,i2c.TRANSMITTER)
    i2c.write(id,reg_addr)
    i2c.start(id)
    i2c.address(id, dev_addr,i2c.RECEIVER)
    c=i2c.read(id,1)
    i2c.stop(id)
    return c
end

function positions()      
    local Xaxis = bit.lshift(string.byte(read_reg(0x33)), 8)
    Xaxis = bit.bor(Xaxis, string.byte(read_reg(0x32)))
    local Yaxis = bit.lshift(string.byte(read_reg(0x35)), 8)
    Yaxis = bit.bor(Yaxis, string.byte(read_reg(0x34)))
    local Zaxis = bit.lshift(string.byte(read_reg(0x37)), 8)
    Zaxis = bit.bor(Zaxis, string.byte(read_reg(0x36)))  
    
    --Clear 3 sign extended MSB bits
    Xaxis=bit.band(0x1FFF, Xaxis)
    Yaxis=bit.band(0x1FFF, Yaxis)
    Zaxis=bit.band(0x1FFF, Zaxis)
    
    if bit.isset(Xaxis, 12) then Xaxis=Xaxis-8193 end
    if bit.isset(Yaxis, 12) then Yaxis=Yaxis-8193 end
    if bit.isset(Zaxis, 12) then Zaxis=Zaxis-8193 end
    
    --4mg/LSB, multiply by 4, should divide by 1000
    Xaxis=Xaxis*4 + 5650
    Yaxis=Yaxis*4 + 5960
    Zaxis=Zaxis*4 + 4500
    
    return {["X"] = Xaxis, ["Y"] = Yaxis, ["Z"] = Zaxis}
end

function M.angle() -- approx angle +90 / -90
    local val = positions()
    local Y = math.max(math.min(val["Y"], 990), -990)
    return Y / -11
end


