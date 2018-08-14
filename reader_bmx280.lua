function readBmx280()
    which = bme280.setup()
    if which == nil then
        return nil, nil, nil
    end
    local temp, pres, humi, QNH
    if which == 1 then
        local i = 0
        while (temp == nil or pres == nil) and i < 100 do
            pres, temp = bme280.baro()
            i = i + 1
        end
        pres, temp = bme280.baro()
        QNH = bme280.qfe2qnh(pres, cfg.altitude)
    else
        temp, pres, humi, QNH = bme280.read(cfg.altitude)
        local i = 0
        while (temp == nil or humi == nil) and i < 100 do
            temp, pres, humi, QNH = bme280.read(cfg.altitude)
            i = i + 1
        end
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
