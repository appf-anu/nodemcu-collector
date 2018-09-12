-- function getVPD(temp, hum)
--   -- SVP
--   local es = 0.6108 * exp(17.27 * temp / (temp + 237.3))
--   -- AVP
--   local ea = hum / 100.0 * es
--   local vpd_kPa = (ea - es) * -1
--   local ah_kgm3 = ea / (461.5 * (temp + 273.15)) * 1000
--   return es, ea, vpd_kPa, ah_kgm3
-- end

function readBme280(cb)
    which = bme280.setup()
    if which == nil or which == 1 then
        return nil
    end
    bme280.startreadout(150, function()
      local temp_c, pa_p, rh_pc, qnh_p = bme280.read(cfg.altitude)
      if temp_c then
          temp_c = temp_c/100
          pa_p = pa_p/10
          qnh_p = qnh_p/10
          rh_pc = rh_pc/1000
          dp_c = bme680.dewpoint(rh_pc, temp_c)
          dp_c = dp_c/100
          cb(temp_c,pa_p,rh_pc,dp_c,qnh_p)
      end
    end)
    return true
end
