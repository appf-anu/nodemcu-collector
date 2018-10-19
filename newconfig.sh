#/bin/bash
nodemcu-tool remove config.lua config.lc
sed -i -E "s/node = .*/node = '$1',/g" config.lua && \
nodemcu-tool upload config.lua && \
nodemcu-tool reset && \
nodemcu-tool terminal
