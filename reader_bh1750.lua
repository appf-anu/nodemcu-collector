function readBh1750()
    i2c.start(0)
    i2c.address(0, 0x23, i2c.TRANSMITTER)
    i2c.write(0, 0x10)
    i2c.stop(0)
    i2c.start(0)
    i2c.address(0, 0x23, i2c.RECEIVER)
    tmr.delay(200000)
    c = i2c.read(0, 2)
    UT = c:byte(1) * 256 + c:byte(2)
    l = (UT*1000/12)
    i2c.stop(0)

    -- print("lux: "..(l / 100).."."..(l % 100).." lx")

    -- release module
    bh1750 = nil
    package.loaded["bh1750"]=nil
    return l/100
end