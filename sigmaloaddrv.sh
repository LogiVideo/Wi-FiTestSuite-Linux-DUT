#!/bin/bash

DIR=/lib/firmware/cypress
chmod 777 *
rmmod bcmdhd
modprobe cfg80211
sleep 1
insmod $DIR/bcmdhd.ko "firmware_path=$DIR/rtecdc.bin nvram_path=$DIR/nvram.txt"
$DIR/wl mpc 0
$DIR/wl up
sleep 1
$DIR/wl isup
sleep 1
$DIR/wl PM 0
IFNAME=`iw dev | grep "Interface" | awk '{print $2}'`
ifconfig $IFNAME up
killall wpa_supplicant
sleep 1
yes | cp *.conf /var/run
$DIR/wpa_supplicant -i $IFNAME -Dnl80211 -c/var/run/wpa_supplicant.conf -m/var/run/p2p_supplicant.conf -puse_p2p_group_interface=1 p2p_device=1 -g/var/run/wpa_global_cmd -dd -B &
ps -aef | grep wpa_supplicant
$DIR/wpa_cli -i $IFNAME remove_net all
$DIR/wpa_cli -i $IFNAME add_n
killall wpa_cli
$DIR/wl down
$DIR/wl amsdu 0
$DIR/wl up
