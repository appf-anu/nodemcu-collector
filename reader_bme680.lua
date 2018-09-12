function readBme680(cb)
    local which = bme280.setup()
    if which == 2 or which == nil then
      return
    end
    which = bme680.setup()
    if which == nil then
        return
    end
    bme680.startreadout(150, function ()
        local temp_c, pa_p, rh_pc, gasr, qnh_p = bme680.read(cfg.altitude)
        if temp_c ~= nil then
            temp_c = temp_c/100
            pa_p = pa_p/10
            qnh_p = qnh_p/10
            rh_pc = rh_pc/1000
            dp_c = bme680.dewpoint(rh_pc, temp_c)
            dp_c = dp_c / 100
            cb(temp_c,pa_p,rh_pc, dp_c, qnh_p)
        end
    end)
    return
end
