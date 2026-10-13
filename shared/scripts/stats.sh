#!/usr/bin/env bash
# Prints key=value lines consumed by Sys.qml
head -1 /proc/stat | sed 's/^/stat=/'
awk '/MemTotal/{t=$2}/MemAvailable/{a=$2}END{printf "ram=%d\n",(t-a)*100/t}' /proc/meminfo
echo "disk=$(df --output=pcent / | tail -1 | tr -dc 0-9)"
echo "ctemp=$(timeout 2 sensors 2>/dev/null | awk '/Package id 0/{gsub(/[^0-9.]/,"",$4);print $4;exit}')"
timeout 3 nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits 2>/dev/null \
  | awk -F', *' '{print "gpu="$1; print "gtemp="$2}'
echo "vol=$(timeout 2 wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)"
echo "wifi=$(timeout 2 nmcli radio wifi 2>/dev/null)"
echo "wname=$(timeout 2 nmcli -t -f TYPE,STATE,CONNECTION dev 2>/dev/null | awk -F: '$1=="wifi"&&$2=="connected"{print $3;exit}')"
echo "bt=$(timeout 2 bluetoothctl show 2>/dev/null | awk '/Powered:/{print $2}')"
echo "rf=$(rfkill list -n -o SOFT 2>/dev/null | sort -u | tr '\n' ' ')"
echo "prof=$(timeout 2 busctl get-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile 2>/dev/null | cut -d\" -f2)"
