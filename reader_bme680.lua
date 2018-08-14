function readBme680()
    which = bme680.setup()
    if which == nil then
        return nil, nil, nil
    end
    local temp, pres, humi, gas, QNH = bme280.read(cfg.altitude)
    local i = 0
    while (temp == nil or humi == nil) and i < 100 do
        temp, pres, humi, gas, QNH = bme280.read(cfg.altitude)
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
  return temp, humi, gas, QNH
end
