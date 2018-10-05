local currentDataBlock = {}


function drawBox(i)
  appStatus.disp:setDrawColor(0)
  appStatus.disp:drawBox(0, 3+(10*i), 64, 10)
  appStatus.disp:setDrawColor(1)
end

function drawDataItem(dataItem)

  if appStatus.disp ~= nil and appStatus.drawing ~= true then
    appStatus.drawing = true
    -- appStatus.disp:clearBuffer()

    local tm = rtctime.epoch2cal(rtctime.get())
    drawBox(0)
    appStatus.disp:drawStr(3, 3, string.format("%04d-%02d-%02d", tm.year, tm.mon, tm.day))

    drawBox(1)
    appStatus.disp:drawStr(3, 13, string.format(" %02d:%02d:%02d",tm.hour, tm.min, tm.sec))

    drawBox(2)
    appStatus.disp:drawStr(3, 23, "ram: "..node.heap())
    drawBox(3)
    local rssi = wifi.sta.getrssi()
    if rssi ~= nil then appStatus.disp:drawStr(3, 33, "sig: "..rssi.."dB") end

    if (dataItem[2] and dataItem[3]) then
      -- remember this is a string until you convert it to a number!
      local vs = tonumber(dataItem[2])
      if vs > 3 then
        drawBox(vs)
        appStatus.disp:drawStr(3, 3+(vs * 10), dataItem[2]..": "..dataItem[3])
      end
    end
    appStatus.disp:drawFrame(0,0,64,128)
    appStatus.disp:sendBuffer()
    appStatus.drawing = false
  end
end

local function reversedipairsiter(t, i)
    i = i - 1
    if i ~= 0 then
        return i, t[i]
    end
end
function reversedipairs(t)
    return reversedipairsiter, t, #t + 1
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

function drawCurrentBlock()
  appStatus.disp:clearBuffer()
  for key, dataItem in pairs(currentDataBlock) do
    drawDataItem(dataItem)
  end
end

if (#currentDataBlock == 0 and #dataQueue > 0) then
  for i,dataItem in reversedipairs(dataQueue) do
    dataItem = stringToDataItem(dataItem)
    table.insert(currentDataBlock, dataItem)
    if #currentDataBlock >= cfg.transmissionBlock then break end
  end
end

drawCurrentBlock()
