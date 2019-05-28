#!/bin/bash
# Bash Color
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'

############################################################
### Build script for HolyDragon kernel ###
############################################################

# This is the full build script used to build the official kernel zip.

# Minimum requirements to build:
# Already working build environment :P 
#
# In this script: 
# You will need to change the 'Source path to kernel tree' to match your current path to this source.
# You will need to change the 'Compile Path to out' to match your current path to this source.
# You will also need to edit the '-j32' under 'Start Compile' section and adjust that to match the amount of cores you want to use to build.
# 
# In Makefile: 
# You will need to edit the 'CROSS_COMPILE=' line to match your current path to this source.
# 
# Once those are done, you should be able to execute './build.sh' from terminal and receive a working zip.

############################################################
# Build Script Variables
############################################################ 

# Toolchain location used to build
	CC_DIR=/home/holyangel/android/Toolchains/Snapdragon_LLVM_v6.0.9/bin/

# Source defconfig used to build
	dc=SD_defconfig

# Source Path to kernel tree
	k=/home/holyangel/android/Kernels/sm8150

# Compile Path to out 
	o="O=/home/holyangel/android/Kernels/sm8150/out"

# CPU threads
	th="-j$(grep -c ^processor /proc/cpuinfo)"

# Source Path to clean(empty) out folder
	co=$k/out

# Source Path to compiled Image.gz-dtb
	i=$k/out/arch/arm64/boot/Image-dtb

# Destination Path for compiled modules
	zm=$k/build/system/lib/modules

# Destination path for compiled Image.gz-dtb
	zi=$k/build/Image-dtb
	
# Source path for building kernel zip
	zp=$k/build/
	
# Destination Path for uploading kernel zip
	zu=$k/upload/

############################################################

# Kernel zip Name
	kn=SDK_OP7_AK2_OOS_V.9.0.zip

############################################################
# Cleanup
############################################################

	echo "	Cleaning up out directory"
	rm -Rf out/
	echo "	Out directory removed!"

############################################################
# Make out folder
############################################################

	echo "	Making new out directory"
	mkdir -p "$co"
	echo "	Created new out directory"

############################################################
# Establish defconfig
############################################################

	echo "	Establishing build environment.."
	make "$o" REAL_CC=${CC_DIR}/clang CLANG_TRIPLE=aarch64-linux-gnu- "$dc"

############################################################
# Start Compile
############################################################

	echo "	First pass started.."
	make "$o" REAL_CC=${CC_DIR}/clang CLANG_TRIPLE=aarch64-linux-gnu- $th
	echo "	First pass completed!"
	echo "	"
	echo "	Starting Second Pass.."
	make "$o" REAL_CC=${CC_DIR}/clang CLANG_TRIPLE=aarch64-linux-gnu- $th
	echo "	Second pass completed!"

############################################################
# Copy image.gz-dtb to /build
############################################################

	echo "	Copying kernel to zip directory"
	cp "$i" "$zi"
#	find . -name "*.ko" -exec cp {} "$zm" \;
	echo "	Copying kernel completed!"

############################################################
# Generating Changelog to /build
############################################################

	./changelog

############################################################
# Make zip and move to /upload
############################################################

	echo "	Making zip file.."
	cd "$zp"
	zip -r "$kn" *
	echo "	Moving zip to upload directory"
	mv "$kn" "$zu" 
	echo "	Completed build script!"
	echo "	Returning to start.."
	cd "$k"
