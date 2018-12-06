#/bin/bash

mkdir -p build
cd build
rm -rf nodemcu-firmware
git clone https://github.com/nodemcu/nodemcu-firmware.git
cd  nodemcu-firmware
git checkout 0abb26170b56178fb5d71451e6688abf2fd3c7e5
cd ..


cat > nodemcu-firmware/app/include/user_modules.h << EOF
#ifndef __USER_MODULES_H__
#define __USER_MODULES_H__

#ifndef LUA_CROSS_COMPILER
//#define LUA_USE_MODULES_ENDUSER_SETUP // USE_DNS in dhcpserver.h needs to be enabled for this module to work.
#define LUA_USE_MODULES_UART

// sensor modules
#define LUA_USE_MODULES_BME280
#define LUA_USE_MODULES_BME680
#define LUA_USE_MODULES_DHT
// bme modules depend on i2c 
#define LUA_USE_MODULES_I2C
// bit module for other things
#define LUA_USE_MODULES_BIT
// so that we can use SHA1 to verify lfs.img
#define LUA_USE_MODULES_CRYPTO
// we need rtctime and SNTP to get the current time.
#define LUA_USE_MODULES_RTCTIME
#define LUA_USE_MODULES_SNTP
// encoder speeds up transfers to the nodemcu
#define LUA_USE_MODULES_ENCODER
// file to store data once out of ram
#define LUA_USE_MODULES_FILE
// gpio for the lights
#define LUA_USE_MODULES_GPIO
// need net to communicate with influxdb
#define LUA_USE_MODULES_NET
// node for internal measurements and other utility
#define LUA_USE_MODULES_NODE
// tmr is needed to do things on an interval
#define LUA_USE_MODULES_TMR
// wifi to communicate
#define LUA_USE_MODULES_WIFI


#endif  /* LUA_CROSS_COMPILER */
#endif  /* __USER_MODULES_H__ */
EOF

sed -i -E "s/.*define LUA_FLASH_STORE.*/#define LUA_FLASH_STORE 0x40000/g" nodemcu-firmware/app/include/user_config.h
sed -i  "s/LFS: disabled/LFS: enabled/" nodemcu-firmware/app/include/user_version.h
docker pull marcelstoer/nodemcu-build:latest
docker run --rm -it -e TZ=Australia/Canberra -e IMAGE_NAME=$(date "+%Y-%m-%d_%H_%M_%S") -v `pwd`/nodemcu-firmware:/opt/nodemcu-firmware:rw marcelstoer/nodemcu-build:latest build

mv nodemcu-firmware/bin/nodemcu*float*.bin ../firmware/
cd ../

# sudo rm -r build
