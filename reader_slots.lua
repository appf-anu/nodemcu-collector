print('reader_slots...')

function readSys(cb)
  local rssi, heap
  heap = node.heap()
  rssi = wifi.sta.getrssi()
  if rssi == nil or heap == nil then
    return
  end
 cb(heap, rssi)
end

require('reader_bh1750')
require('reader_bme280')
require('reader_bme680')
require('reader_dht')

readerSlots = {
  sys = {
    measurementName = 'sys',
    reader = readSys,
    fieldSlots = {heap_size_b = 1, rssi_db = 2},
    readOrder = {[1] = 1, [2] = 2},
  },
  dht22 = {
    measurementName = 'sensors',
    reader = readDht,
    fieldSlots = {temp_c = 3, rh_pc = 5},
    readOrder = {[1] = 3,
                 [2] = 5},
  },
  bme280 = {
    measurementName = 'sensors',
    reader = readBme280,
    fieldSlots = {
        temp_c = 3,
        pa_p = 4,
        rh_pc = 5,
        dp_c = 6,
        qnh_p = 7
    },
    readOrder = {[1] = 3,
                 [2] = 4,
                 [3] = 5,
                 [4] = 6,
                 [5] = 7},
  },
  bme680 = {
    measurementName = 'sensors',
    reader = readBme680,
    fieldSlots = {
        temp_c = 3,
        pa_p = 4,
        rh_pc = 5,
        dp_c = 6,
        qnh_p = 7,
        gasr = 8
      },
    readOrder = {[1] = 3,
                 [2] = 4,
                 [3] = 5,
                 [4] = 6,
                 [5] = 7,
                 [6] = 8}
  },
  bh1750 = {
    measurementName = 'sensors',
    reader = readBh1750,
    fieldSlots = {lux = 9, par = 10},
    readOrder = {[1] = 9, [2] = 10},
  }
}

reverseReaderSlots = {}

for rtag, v in pairs(readerSlots) do
  for fn, slot in pairs(v.fieldSlots) do
    reverseReaderSlots[slot] = {tag = rtag, measure = v.measurementName, field = fn}
  end
end

print(#readerSlots)
