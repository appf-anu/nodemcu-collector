print('read_round ...')
local readerSlots = LFS.reader_slots().readerSlots
local reverseReaderSlots = LFS.reader_slots().reverseReaderSlots
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

function addToDataQueue(measurementId, value)
  local dataItem, deltaTz

  if (#dataQueue == 0) then
    appStatus.baseTz = rtctime.get()
    deltaTz = 0
  else
    deltaTz = rtctime.get() - appStatus.baseTz
  end
  dataItem = {deltaTz, measurementId, value}
  print('time: ' .. dataItem[1], reverseReaderSlots[measurementId].field ..":"..dataItem[2], 'val: ' .. dataItem[3])
  table.insert(dataQueue,  dataItemToString(dataItem))

  if (node.heap() <= cfg.toFileWhenHeap) then
    file.open(cfg.dataFileName, 'a+')
    print('Adding '..#dataQueue..' to file storage.')
    for i = 1, #dataQueue do
      dataItem = table.remove(dataQueue)
      if (dataItem) then
        dataItem = stringToDataItem(dataItem)
        dataItem[1] = appStatus.baseTz + dataItem[1]
        file.writeline(dataItemToString(dataItem))
      end
    end
    file.close()
    appStatus.dataFileExists = true
  end
end

appStatus.reading = true
for key, readerSlot in pairs(readerSlots) do
  readerSlot.reader(function(...)
    for i, v in ipairs(arg) do
      local fslot = readerSlot.readOrder[i]
      if v ~= nil then
        addToDataQueue(fslot, ""..v)
        gpio.write(gpioPins.indicatorLed, gpio.LOW)
      else
        print('Nil value for ' .. key .. '['..i..']')
      end
    end
  end)
end
appStatus.reading = false
