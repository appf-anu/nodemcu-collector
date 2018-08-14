print('main ...')

require('ntp_sync')

dataQueue = {}

reverseReaderSlots = {}

for mn, v in pairs(cfg.readerSlots) do
  for fn, slot in pairs(v.fieldSlots) do
    reverseReaderSlots[slot] = {measure = v.measurementName, field = fn}
  end
end

function dataItemToString(dataItem)
  return dataItem[1] .. ',' .. dataItem[2] .. ',' .. dataItem[3]
end
function stringToDataItem(string)
  local dataItem = {}
  for t, r, v in string.gmatch(string, '(%d+),(%d+),(.+)') do
    dataItem[1] = t
    dataItem[2] = r
    dataItem[3] = v
  end
  return dataItem
end

function unrequire(m)
  package.loaded[m] = nil
  _G[m] = nil
end

node.compile('transmission.lua')
require('transmission')
node.compile('read_round.lua')
require('read_round')

require('wifi_client')
-- Unrequire after 10 sec
timerAllocation.initAlarm = tmr.create()
timerAllocation.initAlarm:alarm(10000, tmr.ALARM_SINGLE, function()
  unrequire('config')
  unrequire('status')
  unrequire('timers')
  unrequire('pins')
end)
