print('transmission ...')
local currentDataBlock = {}
local readerSlots = LFS.reader_slots().readerSlots
local reverseReaderSlots = LFS.reader_slots().reverseReaderSlot
function stringToDataItem(string)
  local dataItem = {}
  for t, r, v in string.gmatch(string, '(%d+),(%d+),(.+)') do
    dataItem[1] = t
    dataItem[2] = r
    dataItem[3] = v
  end
  return dataItem
end

function dataItemToString(dataItem)
 return dataItem[1] .. ',' .. dataItem[2] .. ',' .. dataItem[3]
end

function sendCurrentBlock()
  local tcpSocket
  tcpSocket = net.createConnection(net.TCP, 0)
  tcpSocket:connect(cfg.influxDB.port, cfg.influxDB.host)
  tcpSocket:on('connection', function(sck, c)
    local reverseReaderSlots = {}

    for rtag, v in pairs(readerSlots) do
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
    local request =
      'POST '..'/write?db='..cfg.influxDB.dbname..
      '&u='..cfg.influxDB.username..'&p='..cfg.influxDB.password..
      '&precision=s'..' HTTP/1.1\n' ..
      'Host: '..cfg.influxDB.host..'\n'..
      'Connection: close\n' ..
      'Content-Type: \n' ..
      'Content-Length: '..string.len(ifl)..'\n'..
      '\n'..ifl
    sck:send(request)
  end)

  tcpSocket:on('disconnection', function(sck, c)
    appStatus.transmitting = false
    if (#currentDataBlock == 0 and (#dataQueue > 0 or appStatus.dataFileExists)) then
      node.task.post(node.task.MEDIUM_PRIORITY, LFS.transmission)
    end
  end)

  tcpSocket:on('reconnection', function(sck, c)
    appStatus.transmitting = false
  end)

  tcpSocket:on('receive', function(sck, response)
    local findStart, findEnd
    print(response)
    findStart, findEnd = string.find(response, 'HTTP/1.1 200', 0, true)
    if (findStart) then
      currentDataBlock = {}
    end
    findStart, findEnd = string.find(response, 'HTTP/1.1 204 No Content', 0, true)
    if (findStart) then
      currentDataBlock = {}
    end
  end)
end

if (appStatus.transmitting or appStatus.reading) then
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
  sendCurrentBlock()
else
  appStatus.transmitting = false
end
