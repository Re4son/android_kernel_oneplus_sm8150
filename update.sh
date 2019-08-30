#!/bin/bash
# Bash Color
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'

################################################################
### Single run script for NetHunter Kernel (based on HolyDragon)
################################################################

# This is a cleanup and single run build script for testing purposes.
# This does not zip anything for you, only executes a normal build. 

# Minimum requirements to build:
# cd /opt/Android
# mkdir toolchains && cd toolchains
# git clone https://gitlab.com/HDTC/gclang.git
# git clone https://bitbucket.org/xanaxdroid/aarch64-8.0.git
#
# In this script: 
# You will need to change the 'Source Path to kernel tree' to match your current path to this source.
# You will need to change the 'Compile Path to out' to match your current path to this source.
# You will also need to edit the '-j32' under 'Start Compile' section and adjust that to match the amount of cores you want to use to build.
# 
# In Makefile: 
# You will need to edit the 'CROSS_COMPILE=' line to match your current path to this source.
# 
############################################################
# Build Script Variables
############################################################ 

# Toolchain location used to build
	CC_DIR=/opt/Android/toolchains/gclang/bin/

# Source defconfig used to build
	##dc=nethunter_defconfig
	dc=SD_defconfig

# Source Path to kernel tree
	k=/opt/Android/android_kernel_oneplus_sm8150/

# Compile Path to out 
	o="O=/opt/Android/android_kernel_oneplus_sm8150/out"

# Source Path to clean(empty) out folder
	co=$k/out

# CPU threads
	th="-j$(grep -c ^processor /proc/cpuinfo)"

############################################################
# Cleanup
############################################################

#	echo "	Cleaning up out directory"
#	rm -Rf out/
#	echo "	Out directory removed!"

############################################################
# Make out folder
############################################################

#	echo "	Making new out directory"
#	mkdir -p "$co"
#	echo "	Created new out directory"

############################################################
# Establish defconfig
############################################################

#	echo "	Establishing build environment.."
#	make "$o" REAL_CC=${CC_DIR}/clang CLANG_TRIPLE=aarch64-linux-gnu- "$dc" menuconfig
	
############################################################
# Start Compile
############################################################

	echo "	Starting first build.."
	make "$o" REAL_CC=${CC_DIR}/clang CLANG_TRIPLE=aarch64-linux-gnu- menuconfig
	make "$o" REAL_CC=${CC_DIR}/clang CLANG_TRIPLE=aarch64-linux-gnu- $th
	echo "	Build complete!"


