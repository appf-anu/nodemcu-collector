# nodemcu-collector
Collect measurements from sensors connected to NodeMCU and transmit them to InfluxDB.

This project is intended as starting point for projects where you have to collect data from a set of sensors connected to ESP8266 and any other IoT platform that support NodeMCU firmware.

## Requirements
* A [ESP8266 module](https://en.wikipedia.org/wiki/ESP8266) or similar 
* Knowledge about [NodeMCU platform](http://nodemcu.readthedocs.io/en/master/) and [Lua programming language](http://www.lua.org/manual/5.1/index.html)
* A NodeMCU firmware compiled with these modules at least: dht,bme280,bme680,file,gpio,i2c,net,node,rtctime,sntp,tmr,uart,wifi and lfs enabled. You can compile it easly using http://nodemcu-build.com/ or use the one I compiled earlier in this repository (`nodemcu-master...`)
* [ESplorer](https://github.com/4refr0nt/ESPlorer) or [nodemcu-tool](https://github.com/andidittrich/NodeMCU-Tool) to upload code to the module.
* An accessible instance of [InfluxDB server](https://influxdata.com/time-series-platform/influxdb/)

## Assumptions
* You want collect data from sensors without interaction
* You need the most fiability as possible. It means support wifi or influxdb shutdowns with minor data loss.
* You supply energy to module using a mini UPS device.

## Hardware Setup
We have been having success (and have been officially supporting) using bme280s, bme680s and DHTs for temperature, humidity, pressure and bh1750 for light, however there is no reason why this project couldnt be extended to handle other sensors (see lfs/reader_slots.lua)

## Installation
* Clone or [Download](https://github.com/appf-anu/nodemcu-collector/archive/master.zip) this repository.
* Using [nodemcu-PyFlasher](https://github.com/marcelstoer/nodemcu-pyflasher/releases) flash the firmware in this repository to the nodemcu. Reset the device after flashing.
* Edit `config.lua` according to your environment.
* important fields to add/change:
     - wifiSsid - your wifi ssid
     - wifiPass - your wifi password
     - altitude - your altitude (for calibrated pressure)
     - influxDB: host - the hostname for your influxdb service
     - influxDB: dbname - the database name for influxdb
     - influxDB: username - a user for the influxdb service
     - influxDB: password - a password for the user
     - influxTags: node - a name for the node
* Upload all .lua files and .img files to NodeMCU module and reset it
* Inspect output of serial console of module, you should see a succesful wifi connection info.
* Check data captured on InfluxDB. You will get these measurements: `heap_size_b` and `rssi_db`

## Contributing

The LFS image is compiled using [Terry Ellison's web service](https://blog.ellisons.org.uk/article/nodemcu/a-lua-cross-compile-web-service/). If you make changes to any of the lua code in lfs/ then you will need to zip that directory and upload it to the web service, or you can use my `compilelfs.py` script.

