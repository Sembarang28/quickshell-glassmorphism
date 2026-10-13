#!/usr/bin/env bash
. /etc/os-release
echo "os=$NAME"
echo "host=$(hostname)"
echo "shell=$(basename "$(getent passwd "$(id -un)" | cut -d: -f7)")"
awk '{s=int($1); d=int(s/86400); h=int(s%86400/3600); m=int(s%3600/60); out=""; if(d>0) out=d"d "; printf "uptime=%s%dh %dm\n", out, h, m}' /proc/uptime
echo "pkgs=$(pacman -Qq 2>/dev/null | wc -l)"
echo "kernel=$(uname -r)"
echo "cpu=$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed -E 's/\(R\)|\(TM\)|CPU|Processor| @.*//g; s/ +/ /g; s/^ //; s/ $//')"
echo "gpu=$(timeout 3 nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1 | sed 's/NVIDIA //; s/GeForce //')"
awk '/MemTotal/{printf "ramTotal=%.1f\n",$2/1048576}' /proc/meminfo
