# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers
# Changes for SkyDragon by HolyAngel @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=NetHunter Kernel for the OnePlus 7 (Pro)
do.devicecheck=1
do.modules=0
do.cleanup=0
do.cleanuponabort=0
device.name1=OnePlus7Pro
device.name2=guacamole
device.name3=OnePlus 7 Pro
device.name4=Guacamole
device.name5=OnePlus7
device.name6=guacamoleb
device.name7=OnePlus 7
device.name8=Guacamoleb
device.name9=OnePlus7ProNR
device.name10=OnePlus7ProTMO
device.name11=hotdogb
device.name12=hotdog
device.name13=OnePlus7T
device.name14=OnePlus7TPro
supported.versions=
supported.patchlevels=
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=1;
ramdisk_compression=auto;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;

## Trim partitions
#fstrim -v /cache;
#fstrim -v /data;

## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
set_perm_recursive 0 0 755 644 $ramdisk/*;
set_perm_recursive 0 0 750 750 $ramdisk/init* $ramdisk/sbin;

## AnyKernel install
dump_boot;

# begin ramdisk changes

if [ -d $ramdisk/.backup ]; then
  patch_cmdline "skip_override" "skip_override";
else
  patch_cmdline "skip_override" "";
fi;


# end ramdisk changes

write_boot;


# nethunter part
absar_ramdisk=/system;
$bb mount -o rw,remount -t auto /system;
echo "System:" > /tmp/dbg.txt
echo "-------" >> /tmp/dbg.txt
ls /system >> /tmp/dbg.txt
echo "System_root:" >> /tmp/dbg.txt
echo "------------" >> /tmp/dbg.txt
ls $absar_ramdisk >> /tmp/dbg.txt
echo "absar_ramdisk:" >> /tmp/dbg.txt
echo "------------" >> /tmp/dbg.txt
ls absar_ramdisk/ >>/tmp/dbg.txt
echo "home/absar_ramdisk:" >> /tmp/dbg.txt
echo "-------------------" >> /tmp/dbg.txt
ls $home/absar_ramdisk/ >>/tmp/dbg.txt
set_perm_recursive 0 0 750 750 $home/absar_ramdisk/*;
cp $home/absar_ramdisk/* $absar_ramdisk/ >> tmp/dpg.txt;

if [ ! "$(grep /init.nethunter.rc $absar_ramdisk/init.rc)" ]; then
  insert_after_last "$absar_ramdisk/init.rc" "import .*\.rc" "import /init.nethunter.rc";
fi;

if [ ! "$(grep /dev/hidg* $absar_ramdisk/ueventd.rc)" ]; then
  insert_after_last "$absar_ramdisk/ueventd.rc" "/dev/kgsl.*root.*root" "# HID driver\n/dev/hidg* 0666 root root";
fi;
## end install

