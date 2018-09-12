function getVPD(temp, hum)
  -- SVP
  local es = 0.6108 * exp(17.27 * temp / (temp + 237.3))
  -- AVP
  local ea = hum / 100.0 * es
  local vpd_kPa = (ea - es) * -1
  local ah_kgm3 = ea / (461.5 * (temp + 273.15)) * 1000
  return es, ea, vpd_kPa, ah_kgm3
end

function readBme280()
    which = bme280.setup()
    if which == nil or which == 1 then
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
