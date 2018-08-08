function readSensor()
    i2c.setup(0, gpioPins.sda, gpioPins.scl, i2c.SLOW)
    bme280.setup()
    local temp, pres, humi, QNH = bme280.read(cfg.altitude)
    local i = 0
    while (temp == nil or humi == nil) and i < 10 do
        temp, pres, humi, QNH = bme280.read(cfg.altitude)
        i = i + 1
    end
    if not (temp == nil) then
        temp = temp / 100
    end
    if not (humi == nil) then
        humi = humi / 1000
    end
    if not (QNH == nil) then
        QNH = QNH / 1000
    end
  return temp, humi, QNH
end
