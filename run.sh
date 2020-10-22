###!/usr/bash

#Set BIN_PATH to the path where all wlan binaries (bcmdhd.ko, rtecdc.bin. nvram.txt, clm_blob, wl, dd, wpa_supplicant, wpa_cli) and conf files are kept
BIN_PATH=/home/hnd/acc_drop

#Set CHIP to 89359pcie or 89359sdio or 89335
CHIP=$1

chmod 777 * 
rm -rf /root/sssr*
rm -rf /root/mem*
rm -rf /root/debug*
rm -rf /usr/local/sbin/wl
rm -rf /usr/local/bin/wl
rm -rf /usr/sbin/wl
rm -rf /usr/bin/wl
rm -rf /root/bin/wl
rm -rf /usr/local/sbin/dhd
rm -rf /usr/local/bin/dhd
rm -rf /usr/sbin/dhd
rm -rf /usr/bin/dhd
rm -rf /root/bin/dhd
rm -rf /lib/firmware/cypress
rm -rf /usr/local/bin/wpa_supplicant
rm -rf /usr/local/bin/wpa_cli
dos2unix *

cp -f * $BIN_PATH
sleep 1
cp $BIN_PATH/wl .
cp $BIN_PATH/dhd .
cp $BIN_PATH/wpa_supplicant /usr/local/bin/
cp $BIN_PATH/wpa_cli /usr/local/bin/
sleep 1
chmod 777 $PWD/scripts/*
cp $PWD/scripts/* /usr/local/sbin/
cp $PWD/scripts/* /usr/local/bin/
sleep 1
rmmod bcmdhd
modprobe cfg80211
sleep 1

if [ "$CHIP" == "89359pcie" ]; then
insmod $BIN_PATH/bcmdhd.ko "firmware_path=$BIN_PATH/rtecdc.bin nvram_path=$BIN_PATH/nvram.txt clm_path=$BIN_PATH/4359b1.clm_blob"
sleep 1
./wl down
./wl vht_features 3
./wl amsdu 1
./wl rsdb_mode 0
./wl mpc 0
./dhd -i wlan0 proptx 0
./wl PM 0
./wl rx_amsdu_in_ampdu 1
./wl frameburst 0
./wl up
sleep 1
./wl isup
elif [ "$CHIP" == "89359sdio" ]; then
insmod $BIN_PATH/bcmdhd.ko "firmware_path=$BIN_PATH/rtecdc.bin nvram_path=$BIN_PATH/nvram.txt clm_path=$BIN_PATH/4359b1.clm_blob sd_uhsimode=3 sd_txglom=1 sd_tuning_period=10"
sleep 1
./wl down
./wl vht_features 3
./wl PM 0
./wl mpc 0
./wl amsdu 1
./wl rsdb_mode 0
./dhd -i wlan0 proptx 0
./wl rx_amsdu_in_ampdu 1
./wl up
sleep 1
./wl isup
elif [ "$CHIP" == "89335" ]; then
insmod $BIN_PATH/bcmdhd.ko firmware_path=$BIN_PATH/rtecdc.bin nvram_path=$BIN_PATH/nvram.txt sd_uhsimode=3 sd_txglom=1
sleep 1
./wl down
./dhd -i wlan0 sd_blocksize 2 256
./dhd -i wlan0 txglomsize 40
./wl vht_features 3
./wl PM 0
./wl mpc 0
./dhd -i wlan0 proptx 0
./wl rx_amsdu_in_ampdu 1
./wl up
sleep 1
./wl isup
else
	echo "run.sh: insufficient arguments"
	echo "Please supply CHIP"
        exit 1
fi

ifconfig wlan0 192.165.100.12  netmask 255.255.0.0 up


killall wpa_supplicant
sleep 1
cp $BIN_PATH/*.conf /var/run
/usr/local/bin/wpa_supplicant -i wlan0 -Dnl80211 -c/var/run/wpa_supplicant.conf -m/var/run/p2p_supplicant.conf -puse_p2p_group_interface=1p2p_device=1 -g/var/run/wpa_wlan0_cmd -f./supp_log.txt -dd -B

ps -aef | grep wpa_supplicant


/usr/local/bin/wpa_cli -iwpa_wlan0_cmd remove_n all
/usr/local/bin/wpa_cli -iwpa_wlan0_cmd add_n

cp dut/wfa_dut .
cp ca/wfa_ca .
cp ca/ca.sh .
sleep 1
chmod 777 ca/ca.sh
chmod 777 dut/wfa_dut
chmod 777 ca/wfa_ca
sleep 1

killall wfa_dut
sleep 1
./wfa_dut lo 8000 &


killall wfa_ca
sleep 1
./ca.sh
