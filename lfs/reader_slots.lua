
function writeRegister(dev_addr, value)
    id = 0
    i2c.start(id)
    i2c.address(id, dev_addr, i2c.TRANSMITTER)
    i2c.write(id, value)
    i2c.stop(id)
end

function readRegister(dev_addr, reg_addr, num_bytes)
    id = 0
    i2c.start(id)
    i2c.address(id, dev_addr, i2c.TRANSMITTER)
    i2c.write(id, reg_addr)
    i2c.stop(id)
    i2c.start(id)
    i2c.address(id, dev_addr, i2c.RECEIVER)
    c = i2c.read(id, num_bytes)
    i2c.stop(id)
    return c
end

local readerSlots = {
  sys = {
    measurementName = 'sys',
    reader = function(cb)
      local rssi, heap, versionHash
      heap = node.heap()
      rssi = wifi.sta.getrssi()
      if rssi == nil or heap == nil then
        return
      end
      if file.exists("lfs.img") then
        versionHash = crypto.toHex(crypto.fhash("sha1", "lfs.img"))
      end
     cb(heap, rssi, version)
    end,
    fieldSlots = {heap_size_b = 1, rssi_db = 2, version_hash = 18},
    readOrder = {[1] = 1, [2] = 2, [3] = 18},
  },
  dht22 = {
    measurementName = 'sensors',
    reader = function(cb)
      local status, temp, humi, temp_dec, humi_dec = dht.read(gpioPins.dht)

      if status == dht.OK then
      elseif status == dht.ERROR_CHECKSUM then
          return
      elseif status == dht.ERROR_TIMEOUT then
          return
      end
      cb(temp, humi)
    end,
    fieldSlots = {temp_c = 3, rh_pc = 4},
    readOrder = {[1] = 3,
                 [2] = 4},
  },
  bme280 = {
    measurementName = 'sensors',
    reader = function(cb)
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
    end,
    fieldSlots = {
        temp_c = 5,
        pa_p = 6,
        rh_pc = 7,
        dp_c = 8,
        qnh_p = 9
    },
    readOrder = {[1] = 5,
                 [2] = 6,
                 [3] = 7,
                 [4] = 8,
                 [5] = 9},
  },
  bme680 = {
    measurementName = 'sensors',
    reader = function(cb)
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
                pa_p = pa_p
                qnh_p = qnh_p
                rh_pc = rh_pc/1000
                dp_c = bme680.dewpoint(rh_pc, temp_c)
                dp_c = dp_c / 100
                cb(temp_c,pa_p,rh_pc, dp_c, qnh_p)
            end
        end)
        return
      end,
    fieldSlots = {
        temp_c = 10,
        pa_p = 11,
        rh_pc = 12,
        dp_c = 13,
        qnh_p = 14,
        gasr = 15
      },
    readOrder = {[1] = 10,
                 [2] = 11,
                 [3] = 12,
                 [4] = 13,
                 [5] = 14,
                 [6] = 15}
  },
  bh1750 = {
    measurementName = 'sensors',
    reader = function(cb)
        i2c.start(0)
        found = i2c.address(0, 0x23, i2c.TRANSMITTER)
        if not found then
            return
        end
        i2c.write(0, 0x10)
        i2c.stop(0)
        i2c.start(0)
        i2c.address(0, 0x23, i2c.RECEIVER)
        tmr.delay(200000)
        c = i2c.read(0, 2)
        UT = c:byte(1) * 256 + c:byte(2)
        l = (UT*1000/12)
        i2c.stop(0)
        lux = l/100
        calibPar = lux * cfg.parCalibration
        -- calibPar = lux / cfg.parCalibrationDivisor
        -- print("lux: "..(l / 100).."."..(l % 100).." lx")
        cb(lux, calibPar)
        -- return lux, calibPar
    end,
    fieldSlots = {lux = 16, par = 17},
    readOrder = {[1] = 16, [2] = 17},
  },
  chirpsensor276 = {
    measurementName = 'sensors',
    reader = function(cb)
      -- uncomment the code at the end of this function to enable light sensor.
      -- the sensors I was using are the ruggedized so their light sensor is always covered.
      -- the reason this is disabled is because it takes 2s to read from the light sensor.
      i2c.start(0)
      found = i2c.address(0, 0x20, i2c.TRANSMITTER)
      if not found then
        return
      end

      function decodeChirp(val)
        local b1 = bit.lshift(string.byte(val, 1), 8)
        local b2 = string.byte(val, 2)
        return bit.bor(b1, b2)
      end
      -- clear the sensor
      read_reg(0x20, 0, 2)
      repeat
          tmr.delay(10)
          print("waiting on chirp...")
      until tonumber(read_reg(0x20, 9,1)) == nil

      -- soil capacitance
      local val = readReg(0x20, 0, 2)
      local soil_capacitance = decodeChirp(val)
      -- soil temperature
      val = readReg(0x20, 5, 2)
      local soil_temperature = decodeChirp(val)/10

      -- light
      -- writeRegister(0x20, 3)
      -- tmr.create():alarm(200000, tmr.ALARM_SINGLE, function()
      --   val = readReg(0x20, 4, 2)
      --   local light_ = 65535 - decodeChirp(val)
      --   cb(soil_capacitance, soil_temperature, light)
      --   -- reset sensor
      --   writeRegister(0x20, 6)
      -- end)
      -- reset sensor
      writeRegister(0x20, 6)
      cb(soil_capacitance, soil_temperature, 0)
    end,
    fieldSlots = {soil_capacitance = 19, soil_temperature = 20, light_level = 21},
    readOrder = {[1] = 19, [2] = 20, [3] = 21}
  }
}

local reverseReaderSlots = {}
for rtag, v in pairs(readerSlots) do
  for fn, slot in pairs(v.fieldSlots) do
    reverseReaderSlots[slot] = {tag = rtag, measure = v.measurementName, field = fn}
  end
end

return {readerSlots = readerSlots, reverseReaderSlots = reverseReaderSlots}
