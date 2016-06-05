id=0 --Microcontroller's ID (Master) 
sda=5 
scl=6 
dev_addr=0x1D --Address of accelerometer (Slave)

-- initialize i2c
i2c.setup(id,sda,scl,i2c.SLOW)

i2c.start(id)
i2c.address(id, dev_addr,i2c.TRANSMITTER)
print(string.byte(read_reg(id,0x00)))
i2c.write(id,0x2D) --Power control register
i2c.write(id,0x00) --Activate standby mode to configure device
i2c.stop(id)

i2c.start(id)
i2c.address(id, dev_addr,i2c.TRANSMITTER)
i2c.write(id,0x31) --Data format register
i2c.write(id,0x0B) --Set g range to 16, Full res
i2c.stop(id)

i2c.start(id)
i2c.address(id, dev_addr,i2c.TRANSMITTER)
i2c.write(id,0x2C) --BW rate register
i2c.write(id,0x0A) --Data rate 100Hz
i2c.stop(id)

i2c.start(id)
i2c.address(id, dev_addr,i2c.TRANSMITTER)
i2c.write(id,0x2D) --Power control register
i2c.write(id,0x08) --Activate measure mode
i2c.stop(id)

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

function adxl()
  X0 = read_reg(0x32)
  X1 = read_reg(0x33)
  Y0 = read_reg(0x34)
  Y1 = read_reg(0x35)
  Z0 = read_reg(0x36)
  Z1 = read_reg(0x37)

  --Combine 2 bytes to get a single 16bit number
  Xtemp = bit.lshift(string.byte(X1), 8)
  Xaxis = bit.bor(Xtemp, string.byte(X0))
  Ytemp = bit.lshift(string.byte(Y1), 8)
  Yaxis = bit.bor(Ytemp, string.byte(Y0))
  Ztemp = bit.lshift(string.byte(Z1), 8)
  Zaxis = bit.bor(Ztemp, string.byte(Z0))  

  --Clear 3 sign extended MSB bits
  Xaxis=bit.band(0x1FFF, Xaxis)
  Yaxis=bit.band(0x1FFF, Yaxis)
  Zaxis=bit.band(0x1FFF, Zaxis)

  --Check if number is negative
  Xn=bit.band(0x1000, Xaxis)
  Yn=bit.band(0x1000, Yaxis)
  Zn=bit.band(0x1000, Zaxis)

  --If negative, convert twos complement number to decimal(-8193=-8192-1)
  if Xn==4096 then Xaxis=Xaxis-8193 end
  if Yn==4096 then Yaxis=Yaxis-8193 end
  if Zn==4096 then Zaxis=Zaxis-8193 end

  --4mg/LSB, multiply by 4, should divide by 1000
  Xaxis=Xaxis*4
  Yaxis=Yaxis*4
  Zaxis=Zaxis*4

  print(Xaxis)
  print(Yaxis)
  print(Zaxis)

end
