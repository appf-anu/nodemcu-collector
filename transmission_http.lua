print('transmission ...')
local currentDataBlock = {}

function doTransmission()
  if (appStatus.transmitting) then
    return true
  end
  appStatus.transmitting = true
  local dataItem
  if (appStatus.dataFileExists and #currentDataBlock == 0) then
    file.open(cfg.dataFileName)
    file.seek('set', appStatus.lastSeekPosition)
    print('Reading data storage')
    repeat
      dataItem = file.readline()
      if (dataItem) then
        dataItem = string.sub(dataItem, 1, (#dataItem - 1))
        table.insert(currentDataBlock, dataItem)
      end
    until (dataItem == nil or #currentDataBlock >= cfg.transmissionBlock)
    if (dataItem == nil) then
      file.close()
      file.remove(cfg.dataFileName)
      appStatus.dataFileExists = false
      appStatus.lastSeekPosition = 0
    else
      appStatus.lastSeekPosition = file.seek()
      file.close()
    end
  end
  if (#currentDataBlock == 0 and #dataQueue > 0) then
    local itemsToCopy
    if (#dataQueue > cfg.transmissionBlock) then
      itemsToCopy = cfg.transmissionBlock
    else
      itemsToCopy = #dataQueue
    end
    repeat
      dataItem = table.remove(dataQueue)
      if (dataItem) then
        dataItem = stringToDataItem(dataItem)
        dataItem[1] = appStatus.baseTz + dataItem[1]
        table.insert(currentDataBlock, dataItemToString(dataItem))
      end
    until (dataItem == nil or #currentDataBlock >= cfg.transmissionBlock)
  end

  if (#currentDataBlock > 0 and appStatus.wifiConnected) then
    print("sending current data block")
    sendCurrentBlock()
    appStatus.transmitting = false
  else
    appStatus.transmitting = false
  end
end

function sendCurrentBlock()
  local reverseReaderSlots = {}
  -- print("Connected to "..cfg.influxDB.host)
  for rtag, v in pairs(cfg.readerSlots) do
    for fn, slot in pairs(v.fieldSlots) do
      reverseReaderSlots[slot] = {tag = rtag, measure = v.measurementName, field = fn}
    end
  end
  local tagsLine = ''
  for tag, value in pairs(cfg.influxTags) do
    tagsLine = tagsLine .. tag .. '=' .. value .. ','
  end
  tagsLine = string.sub(tagsLine, 1, (#tagsLine - 1))
  local ifl = ''
  for key, stringItem in pairs(currentDataBlock) do
    local dataItem = stringToDataItem(stringItem)
    if (dataItem[2] and dataItem[3]) then
      -- remember this is a string until you convert it to a number!
      local vs = tonumber(dataItem[2])
      local rrs = reverseReaderSlots[vs]
      ifl = ifl ..
        rrs.measure..','..tagsLine..",stype="..rrs.tag..' '..
        rrs.field..'='..dataItem[3]..' '..dataItem[1]..'\n'
    end
  end
  print(ifl)
  -- local request =
  --   'POST '..'/write?db='..cfg.influxDB.dbname..
  --   '&u='..cfg.influxDB.username..'&p='..cfg.influxDB.password..
  --   '&precision=s'..' HTTP/1.1\n' ..
  --   'Host: '..cfg.influxDB.host..'\n'..
  --   'Connection: close\n' ..
  --   'Content-Type: \n' ..
  --   'Content-Length: '..string.len(ifl)..'\n'..
  --   '\n'..ifl
    local uri = cfg.influxDB.url..'write?db='..cfg.influxDB.dbname..
    '&u='..cfg.influxDB.username..'&p='..cfg.influxDB.password..
    '&precision=s'
    print(uri)
    http.post(uri, nil, ifl, function(code, data)
      print(code)
      print(data)
      -- if code == 200 then
      --   dataQueue = {}
      -- end
    end)
end

timerAllocation.transmission = tmr.create()
timerAllocation.transmission:register(
  cfg.transmissionInterval,
  tmr.ALARM_AUTO,
  doTransmission
)
tmr.start(timerAllocation.transmission)

appStatus.dataFileExists = file.exists(cfg.dataFileName)
