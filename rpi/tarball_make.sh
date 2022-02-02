#!/bin/bash
ARCH="arm64"
KERNEL="kernel8"
TMP=`mktemp -d`
T_PATH="~/pi-64-drm-sched-v3"

set -eu
 
verheader=include/generated/utsrelease.h
 
if ! test -f "$verheader"; then
    echo "Missing $verheader" >&2
    exit 1
fi
 
ver=$(sed -rn 's/.*UTS_RELEASE +"([^"]*)".*/\1/p' < "$verheader")
 
tar=$(echo "$ver" | sed -rn 's/.*-drm(.*)++(.*)/pi-drm\1.tgz/p')
 
if test -z "$tar"; then
    echo "Failed to get tarball name from \"$ver\"" >&2
    exit 1
fi   

#make ARCH=$ARCH CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=$TMP modules_install
make ARCH=$ARCH CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=$TMP modules_install

#mkdir -p $TMP/boot $TMP/boot/overlays $TMP/lib/modules/

# Find here: https://github.com/raspberrypi/firmware/tree/master/boot
#cp $USB/boot/kernel7l.img $TMP/boot/
#cp $USB/boot/*.dat $TMP/boot/
#cp $USB/boot/*.elf $TMP/boot/
#cp $USB/boot/*.bin $TMP/boot/
#cp $USB/boot/bcm*-rpi*.dtb $TMP/boot/
#cp $USB/boot/overlays/*.dtb* $TMP/boot/overlays

cp arch/$ARCH/boot/Image $T_PATH/boot/$KERNEL.img
cp arch/$ARCH/boot/dts/broadcom/*.dtb $T_PATH/boot/
#cp arch/$ARCH/boot/zImage $T_PATH/boot/$KERNEL.img
#cp arch/$ARCH/boot/dts/*.dtb $T_PATH/boot/
cp arch/$ARCH/boot/dts/overlays/*.dtb* $T_PATH/boot/overlays
cp arch/$ARCH/boot/dts/overlays/README $T_PATH/boot/overlays

set -x

tar -zcf ~/"$tar" -C $T_PATH boot -C $TMP lib
rm -rf $TMP
