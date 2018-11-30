#/bin/bash
firmware=`ls -t firmware/* | head -1`
echo "writing firmware $firmware"

esptool -b 921600 --port /dev/ttyUSB0 erase_flash
esptool -b 921600 --port /dev/ttyUSB0 write_flash -fm dio 0x000000 $firmware
