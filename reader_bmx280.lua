function readBmx280()
    bme280.setup()
    local temp, pres, humi, QNH = bme280.read(cfg.altitude)
    local i = 0
    while (temp == nil or humi == nil) and i < 10 do
        temp, pres, humi, QNH = bme280.read(cfg.altitude)
        i = i + 1
    end
    if temp ~= nil then
        temp = temp / 100
    end
    if humi ~= nil then
        humi = humi / 1000
    end
    if QNH ~= nil then
        QNH = QNH / 10
    end
  return temp, humi, QNH
end
