print('read_round ...')
-- For comparing against captureDelta
local lastValues = {}

function doReadRound()
  for key, readerSlot in pairs(cfg.readerSlots) do
    -- get values
    local vl = {readerSlot.reader()}
    -- iterate over returned vl
    for i, v in ipairs(vl) do
      -- this is to add to the correct field slot
      local ri = 1
      for fn, fslot in pairs(readerSlot.fieldSlots) do
        if ri == i then
          addToDataQueue(fslot, v)
          break
        end
        ri = ri + 1
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

  -- When last heap lower than config value then save dataQueue to file
  local lastNodeHeap = lastValues[cfg.readerSlots.nodeHeap.fieldSlots.heap_size]
  if (lastNodeHeap and lastNodeHeap <= cfg.toFileWhenHeap) then
    file.open(cfg.dataFileName, 'a+')

  print('adding '..#dataQueue..'to storage.')
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
