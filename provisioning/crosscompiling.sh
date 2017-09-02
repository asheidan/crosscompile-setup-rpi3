#!/bin/bash

set -e

cd $(dirname $0)
root=$(pwd)

###############################################################################
arch=arm
cross_compile=${arch}-linux-gnueabihf-
platform=bcm2709

###############################################################################
srcdir="${root}/linux"
builddir="${root}/build"
toolsdir="tools-master/${arch}-bcm2708/gcc-linaro-${cross_compile}raspbian-x64"

###############################################################################
make="make -j 3"
###############################################################################


if [ ! -e tools.tgz ]; then
	echo "Downloading tools"
	(
		set -x
		curl -L -o tools.tgz https://github.com/raspberrypi/tools/archive/master.tar.gz
	)
fi

if [ ! -e "${toolsdir}" ]; then
	echo "Extracting tools"
	(
		set -x
		tar -xzf tools.tgz "${toolsdir}"
	)
fi

if [ ! -e "bin" ]; then
	echo "Symlinking bin-directory"
	(
		set -x
		ln -s "${root}/${toolsdir}"/bin bin
	)
fi

if [ ! -e "${srcdir}" ]; then
	echo "Cloning kernel repo"
	(
		set -x
		git clone --depth=1 https://github.com/raspberrypi/linux
	)
fi

which ${arch}-linux-gnueabihf-gcc > /dev/null 2>&1 || (
	echo "Could not find gcc to use for crosscompilation."
	echo "You probably need to change your PATH to include the tools directory"
	exit 1
)

which bc > /dev/null 2>&1 || (
	echo "Installing dependencies needed for building"
	set -x
	sudo apt-get update
	sudo apt-get install bc
)

if [ ! -e "${builddir}/.config" ]; then
	echo "Configuring kernel"
	(
		set -x
		cd "${srcdir}"
		${make} O="${builddir}" ARCH=${arch} CROSS_COMPILE=${cross_compile} ${platform}_defconfig
	)
fi

if [ ! -e "${builddir}/arch/${arch}/boot/zImage" ]; then
	echo "Building kernel (This will take quite a while...)"
	(
		set -x
		cd "${srcdir}"
		${make} O="${builddir}" ARCH=${arch} CROSS_COMPILE=${cross_compile} zImage modules dtbs
	)
fi
