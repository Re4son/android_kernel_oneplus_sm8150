# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers
# Changes for SkyDragon by HolyAngel @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=SkyDragon Kernel for the OnePlus 7 Pro
do.devicecheck=1
do.modules=0
do.cleanup=1
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
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=1;
ramdisk_compression=auto;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;

## Trim partitions
fstrim -v /cache;
fstrim -v /data;

## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
chmod -R 750 $ramdisk/*;
chown -R root:root $ramdisk/*;

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
## end install

