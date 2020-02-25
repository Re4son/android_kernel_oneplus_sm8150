##!/bin/bash
# Bash Color
green='\e[32m'
red='\e[31m'
yellow='\e[33m'
blink_red='\033[05;31m'
restore='\033[0m'
reset='\e[0m'

#SkyDragon Kernel Build Script
##############################################

# Kernel zip Name
kn=SDK_OP7TP_OOS10_RV.6.3.zip

export LOCALVERSION=-SDK_OP7TP_OOS10_DV.6.5

# Resource Locations
##############################################
# Target Architecture
export ARCH=arm64
# Target Sub-Architecture
export SUBARCH=arm64
# Path To Clang
export CLANG_PATH=/android/toolchains/gclang/bin/
# Export Clang Path to $PATH
export PATH=${CLANG_PATH}:${PATH}
# Clang Target Triple
export CLANG_TRIPLE=aarch64-linux-gnu-
# Location of Aarch64 GCC Toolchain *
export CROSS_COMPILE=/android/toolchains/aarch64-9.1/bin/aarch64-linux-gnu-
# Location Arm32 GCC Toolchain *
export CROSS_COMPILE_ARM32=/android/toolchains/arm-cortex_a15-linux-gnueabihf/bin/arm-cortex_a15-linux-gnueabihf-
# Export Clang Libary To LD Library Path
export LD_LIBRARY_PATH=/android/toolchains/gclang/lib64:$LD_LIBRARY_PATH


# Paths
##############################################
# Map current directory
KERNEL_DIR=`pwd`
# Source Path to kernel tree
k="/android/kernels/sm8150qs"

# CPU threads
# All Available cores (Used for normal compilation)
th="-j$(grep -c ^processor /proc/cpuinfo)"
# 12 Cores Only: Recompile (Only used for 'recompiles' to catch errors more easily)
thrc="-j12"

# Path to source defconfig used to build
dc=SD_defconfig

# Image Type (Only ONE of the following (lz4/gz) can Enabled!)
# GZ Image (Uncomment to Enable)
img_gz=Image.gz-dtb
# Source Path to compiled Image.gz-dtb
io=$k/out/arch/arm64/boot/$img_gz
# Destination path for compiled Image.gz-dtb
zi=$k/build/$img_gz

### lz4 image (Uncomment to Enable)
# img_lz4=Image.lz4-dtb
## Source Path to compiled Image.lz4-dtb
# io=$k/out/arch/arm64/boot/$img_lz4
## Destination path for compiled Image.lz4-dtb
# zi=$k/build/$img_lz4

# DTBToolCM
dtbtool=$k/build/tools/dtbToolCM
# Destination path for compiled dtb image
zd=$k/build/dtb

# DTBO Image
dtbo=dtbo.img
# Source Path to compiled dtbo image
j=$k/out/arch/arm64/boot/$dtbo
# Destination path for compiled dtbo image
zj=$k/build/$dtbo

# Compile Path to out 
o="O=$k/out"
# Source Path to clean(empty) out folder
co=$k/out

# Source path for building kernel zip
zp=$k/build/

# Destination patch for Changelog
zc=$k/build/Changelog.txt

# Destination Path for compiled modules
zm=$k/build/system/lib/modules

# Destination Path for uploading kernel zip
zu=$k/upload/


# Functions
##############################################
# Function to Pause
function pause() {
	local message="$@"
	[ -z $message ] && message="Press [Enter] key to continue.."
	read -p "$message" readEnterkey
}

# Function to clean up pregenerated images
function make_bclean {
		echo
		echo -e "${yellow}Cleaning up pregenerated images${red}"
		rm -rf $zd
		rm -rf $zi
		rm -rf $zj
		rm -rf $zc
		echo -e "${green}Completed!${restore}"
}

# Function to clean generated out folder
function make_oclean {
		echo
		echo -e "${yellow}Cleaning up out directory${red}"
		rm -rf "$co"
		echo -e "${green}Out directory removed!${restore}"
}

# Funtion to clean source tree
function make_sclean {
		echo
		echo -e "${yellow}Cleaning source directory..${red}"
		make clean && make mrproper
		echo -e "${green}Cleaning Completed!${restore}"
}

# Function to clean up pregenerated images
function make_fclean {
		echo
		make_bclean
		make_oclean
		make_sclean
		pause
}

# Function to only compile the kernel
function make_kernel {
		echo
		make_oclean
		echo -e "${yellow}Making new out directory"
		mkdir -p "$co"
		echo -e "${green}Created new out directory"
		echo -e "${yellow}Establishing build environment..${restore}"
		make "$o" CC=clang $dc
		echo -e "${yellow}~~~~~~~~~~~~~~~~~~"
		echo -e "${yellow}Starting Compile.."
		echo -e "${yellow}~~~~~~~~~~~~~~~~~~${restore}"
		time make "$o" CC=clang $th
		echo -e "${green}Compilation Successful!${restore}"
		pause
}

# Function to recompile the kernel at a slower rate
# after fixing an error without starting over
function recompile_kernel {
		echo
		echo -e "${yellow}Picking up where you left off..${restore}"
		time make "$o" CC=clang $thrc
		echo -e "${green}Compilation Successful!${restore}"
		pause
}

# Function to generate the kernel zip
function make_zip {
		echo
		echo -e "${yellow}Copying kernel to zip directory..${red}"
		cp "$io" "$zi"
		# Uncomment to enable dtbo
#		echo -e "${yellow}Copying dtbo to zip directory..${red}"
#		cp "$j" "$zj"
		# Uncomment to enable dtb
#		echo
#		make_dtb
		echo -e "${green}Copy Successful${restore}"
		make_clog
		echo
		echo -e "${yellow}Making zip file....${red}"
		cd "$zp"
		zip -r "$kn" *
		echo -e "${yellow}Moving zip to upload directory"
		mv "$kn" "$zu" 
		echo -e "${green}Completed build script!${restore}"
		cd $k
		echo -e "${restore}Back at Start"
		pause
}

# Function to generate a dtb image
function make_dtb {
		echo
		echo -e "${yellow}Generating DTB Image"
		$dtbtool -2 -o $zd -s 2048 -p $co/scripts/dtc/ $co/arch/arm64/boot/dts/qcom/
		echo -e "${green}DTB Generated!${restore}"
}

# Generate Changelog
function make_clog {
		echo
		echo -e "${yellow}Generating Changelog.."
		rm -rf $zc
		touch $zc
	for i in $(seq 180);
	do
		local After_Date=`date --date="$i days ago" +%F`
		local kcl=$(expr $i - 1)
		local Until_Date=`date --date="$kcl days ago" +%F`
		echo "====================" >> $zc;
		echo "     $Until_Date    " >> $zc;
		echo "====================" >> $zc;
		git log --after=$After_Date --until=$Until_Date --pretty=tformat:"%h  %s  [%an]" --abbrev-commit --abbrev=7 >> $zc
		echo "" >> $zc;
	done
		sed -i 's/project/ */g' $zc
		sed -i 's/[/]$//' $zc
		echo -e "${yellow}Changelog Complete!${restore}"
}

# Function to build the full kernel zip
function make_full {
		echo
		make_bclean
		make_sclean
		make_kernel
		make_zip
}

# Main Menu
##############################################
# Function to display menu
 show_menus() {
		clear
		echo "	~~~~~~~~~~~~~~~~~~"
		echo "	M A I N - M E N U"
		echo "	~~~~~~~~~~~~~~~~~~"
		echo "	1. Compile Kernel"
		echo "	2. Recompile Kernel"
		echo "	3. Generate Kernel Zip"
		echo "	4. Generate Changelog"
		echo "	5. Make Full Build"
 		echo "	6. Clean Environment"
  		echo "	7. Exit"
}
# Function to read menu choices
read_options(){
	local choice
	read -p "Enter choice [1-7] " choice
	case $choice in
		1) make_kernel ;;
		2) recompile_kernel ;;
		3) make_zip ;;
		4) make_clog ;;
		5) make_full ;;
		6) make_fclean ;;
		7) exit 0;;
		*) echo -e "${red}Error...${restore}" && sleep 2
	esac
}

# Main Logic
while true
do
	clear
	show_menus
	read_options
done