#/bin/bash
esptool -b 921600 --port /dev/ttyUSB0 write_flash -fm dio 0x000000 firmware/nodemcu_float_2018-*
nodemcu-tool mkfs --noninteractive
