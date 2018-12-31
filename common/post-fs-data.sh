# Post Fs controller script
# with QC Hexagon DTS script by UltraM8, Zackptg5 and Michi_Nemuritor fixes
change_module() {
  if [ "$1" ]; then
    for FILE in $1; do
      chmod 666 $FILE
      echo "$2" > $FILE
      chmod 444 $FILE
    done
  fi
}
set_metadata() {
  file="$1"
  if [ -e "$file" ]; then
    shift
    until [ ! "$2" ]; do
    case $1 in
      uid) chown "$2" "$file";;
      gid) chown :"$2" "$file";;
      mode) chmod "$2" "$file";;
      capabilities) ;;
      selabel)
      chcon -h "$2" "$file"
      chcon "$2" "$file"
      ;;
      *) ;;
    esac
    shift 2
    done
  fi
}

#Force high performance DAC by ZeroInfinity@XDA
## requires custom kernel support for uhqa
HPM=$(find $ROOT/sys/module -name high_perf_mode)
change_module "$HPM" "1"

#Force impedance detection by UltraM8@XDA
IDE=$(find $ROOT/sys/module -name impedance_detect_en)
change_module "$IDE" "1"

#Preallocate DMA memory buffer expander by UltraM8@XDA
MSS=$(find $ROOT/sys/module -name maximum_substreams)
change_module "$MSS" "16"

#Double-volume for htc's 3.5 amp
BTS=$(find $ROOT/sys/devices/virtual/switch/beats/state)
change_module "$BTS" "1"


# Reset dts effects each boot
for EFFECT in /data/misc/dts/effect*; do
  cp -f /data/misc/dts/origeffect.bak $EFFECT
done

### Michi_Nemuritor fix ###
# based on GH
chmod 660 /dev/dts_eagle
chown system:audio /dev/dts_eagle

(
  sleep 10
  chmod 771 /data/misc/dts
)&

for FILE in /data/misc/dts/*; do
  chcon 'u:object_r:dts_data_file:s0' $FILE
  set_metadata $FILE uid 0 gid 0 mode 0666 capabilities 0x0 selabel u:object_r:audioserver:s0
done
