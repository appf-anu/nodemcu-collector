function readDht(cb)
  local status, temp, humi, temp_dec, humi_dec = dht.read(gpioPins.dht)

  if status == dht.OK then
  elseif status == dht.ERROR_CHECKSUM then
      return
  elseif status == dht.ERROR_TIMEOUT then
      return
  end
  cb(temp, humi)
end
