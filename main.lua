print('main ...')

require('ntp_sync')

dataQueue = {}

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
require('transmission')
require('read_round')
require('wifi_client')
require('wifi_client')
print("heap: "..node.heap())

tmr.create():alarm(7000, tmr.ALARM_SINGLE, function()
  require('reader_slots')
  print("heap: "..node.heap())
  require('transmission_http')
  print("heap: "..node.heap())
  require('read_round')
  print("heap: "..node.heap())
  -- require('telnetsrv')
  -- print("heap: "..node.heap())
end)

-- Unrequire after 10 sec
tmr.create():alarm(10000, tmr.ALARM_SINGLE, function()
  unrequire('config')
  unrequire('status')
  unrequire('timers')
  unrequire('pins')
  unrequire('wifi_client')
end)
