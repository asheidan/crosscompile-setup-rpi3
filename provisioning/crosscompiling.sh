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
if [ $(uname -m) == "x86_64" ]; then
	toolsdir="tools-master/${arch}-bcm2708/gcc-linaro-${cross_compile}raspbian-x64"
else
	toolsdir="tools-master/${arch}-bcm2708/gcc-linaro-${cross_compile}raspbian"
fi

###############################################################################
make="make -j 3"
###############################################################################

for tool in curl tar make gcc git; do
	which $tool > /dev/null 2>&1 || (
		echo "Could not find ${tool} in your PATH."
		echo "You should probably install it..."
		echo "Perhaps: sudo apt-get install $tool"
		exit 1
	)
done


if [ ! -e tools.tgz ]; then
	echo "### Downloading tools"
	(
		set -x
		curl -L -o tools.tgz https://github.com/raspberrypi/tools/archive/master.tar.gz
	)
fi

if [ ! -e "${toolsdir}" ]; then
	echo "### Extracting tools"
	(
		set -x
		tar -xzf tools.tgz "${toolsdir}"
	)
fi

if [ ! -e "bin" ]; then
	echo "### Symlinking bin-directory"
	(
		set -x
		ln -s "${root}/${toolsdir}"/bin bin
	)
fi

if [ ! -e "${srcdir}" ]; then
	echo "### Cloning kernel repo"
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

if [ ! -e "${builddir}/.config" ]; then
	echo "### Configuring kernel"
	(
		set -x
		cd "${srcdir}"
		KERNEL=kernel7
		${make} O="${builddir}" ARCH=${arch} CROSS_COMPILE=${cross_compile} ${platform}_defconfig
	)
fi

if [ ! -e "${builddir}/arch/${arch}/boot/zImage" ]; then
	echo "### Building kernel for the first time (This will take quite a while...)"
fi
echo "### Building kernel"
(
	set -x
	cd "${srcdir}"
	time ${make} O="${builddir}" ARCH=${arch} CROSS_COMPILE=${cross_compile} zImage modules dtbs
)
