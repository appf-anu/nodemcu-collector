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

require('reader_slots')
require('read_round')
require('transmission')
require('wifi_client')

print("heap: "..node.heap())

-- Unrequire after 10 sec
tmr.create():alarm(10000, tmr.ALARM_SINGLE, function()
  print("unrequiring...")
  unrequire('config')
  unrequire('status')
  unrequire('timers')
  unrequire('pins')
  if cfg.enableTelnet == true and appStatus.wifiConnected then
    require('telnetsrv')
  end
end)
