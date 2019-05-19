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

# Compile Path to out 
	o="O=/home/holyangel/android/Kernels/sm8150/out"

# CPU threads
	th="-j32"

############################################################
# Start Compile
############################################################

	echo "	Starting up from where you left off.."
	make "$o" REAL_CC=${CC_DIR}/clang CLANG_TRIPLE=aarch64-linux-gnu- $th
	echo "	Build completed!"

