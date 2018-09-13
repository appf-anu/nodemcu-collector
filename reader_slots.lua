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
    fieldSlots = {temp_c = 3, rh_pc = 4},
    readOrder = {[1] = 3,
                 [2] = 4},
  },
  bme280 = {
    measurementName = 'sensors',
    reader = readBme280,
    fieldSlots = {
        temp_c = 5,
        pa_p = 6,
        rh_pc = 7,
        dp_c = 8,
        qnh_p = 9
    },
    readOrder = {[1] = 5,
                 [2] = 6,
                 [3] = 7,
                 [4] = 8,
                 [5] = 9},
  },
  bme680 = {
    measurementName = 'sensors',
    reader = readBme680,
    fieldSlots = {
        temp_c = 10,
        pa_p = 11,
        rh_pc = 12,
        dp_c = 13,
        qnh_p = 14,
        gasr = 15
      },
    readOrder = {[1] = 10,
                 [2] = 11,
                 [3] = 12,
                 [4] = 13,
                 [5] = 14,
                 [6] = 15}
  },
  bh1750 = {
    measurementName = 'sensors',
    reader = readBh1750,
    fieldSlots = {lux = 16, par = 17},
    readOrder = {[1] = 16, [2] = 17},
  }
}

reverseReaderSlots = {}
for rtag, v in pairs(readerSlots) do
  for fn, slot in pairs(v.fieldSlots) do
    reverseReaderSlots[slot] = {tag = rtag, measure = v.measurementName, field = fn}
  end
end
