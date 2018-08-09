function readBmx280()
    i2c.setup(0, gpioPins.sda, gpioPins.scl, i2c.SLOW)
    bme280.setup()
    local temp, pres, humi, QNH = bme280.read(cfg.altitude)
    local i = 0
    while (temp == nil or humi == nil) and i < 10 do
        temp, pres, humi, QNH = bme280.read(cfg.altitude)
        i = i + 1
    end
    temp = temp / 100
    humi = humi / 1000
    QNH = QNH / 10
  return temp, humi, QNH
end
