#/bin/bash
sha1=$(sha1sum lfs.img|cut -f 1 -d' ')
echo "lfs.img hash: $sha1"
nodemcu-tool remove init.lua
nodemcu-tool reset
nodemcu-tool upload --minify --compile main.lua programData.lua screen.lua trig.lua && \
sed -i -E "s/node = .*/node = '$1',/g" config.lua && \
nodemcu-tool upload lfs.img init.lua config.lua && \
nodemcu-tool reset && \
nodemcu-tool terminal
