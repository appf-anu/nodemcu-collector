#/bin/bash
nodemcu-tool upload --minify --compile main.lua programData.lua screen.lua trig.lua && \
sed -i -E "s/node = .*/node = '$1',/g" config.lua && \
nodemcu-tool upload lfs.img init.lua config.lua && \
nodemcu-tool reset && \
nodemcu-tool terminal
