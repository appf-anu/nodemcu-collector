#/bin/bash
cd build
mkdir -p lfs
cp -r ../lfs/* lfs/
docker run --rm -it -e TZ=Australia/Canberra -v `pwd`/nodemcu-firmware:/opt/nodemcu-firmware:rw -v `pwd`/lfs:/opt/lua:rw marcelstoer/nodemcu-build:latest lfs-image

mv -f lfs/LFS_float* ../lfs.img
rm -r lfs/*
cd ../
