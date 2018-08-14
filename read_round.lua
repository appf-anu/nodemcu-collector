print('read_round ...')

function doReadRound()
  if appStatus.configured then
    for key, readerSlot in pairs(cfg.readerSlots) do
      -- get values
      local vl = {readerSlot.reader()}
      -- iterate over returned values
      for i, v in ipairs(vl) do
        local fslot = readerSlot.readOrder[i]
        addToDataQueue(fslot, v)
      end
    end
  end
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

  print('tz: ' .. dataItem[1], 'Reader Id: ' .. dataItem[2], 'Value: ' .. dataItem[3])
  table.insert(dataQueue, dataItemToString(dataItem))

  if (node.heap() <= cfg.toFileWhenHeap) then
    file.open(cfg.dataFileName, 'a+')

  print('adding '..#dataQueue..' to storage.')
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

timerAllocation.readRound = tmr.create()
timerAllocation.readRound:register(
  cfg.readRoundInterval,
  tmr.ALARM_AUTO,
  doReadRound
)
tmr.start(timerAllocation.readRound)
