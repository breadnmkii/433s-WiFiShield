#!/bin/bash

###
#   NOTE: DO NOT RUN THIS SCRIPT INDEPENDENTLY!!!
#   Use the WiFiShield.sh script and the Shield Utility
###

echo $1 $2

if [ $# != 2 ]
then
    echo "Do not run this individually; run WifiShield"
    exit;
fi

# @param
# $1: $WLAN_MAC
# $2: $WLAN_NAME
BLACKLIST_PATH="blacklist.txt"

if [ ! -f "$BLACKLIST_PATH" ]
    then
        touch $BLACKLIST_PATH
    fi

echo "Deauthing MAC addresses: "
while read TGT_MAC
do
    echo $TGT_MAC
done < $BLACKLIST_PATH
echo "Press CTRL+C to terminate..."
while [ true ]
do
    while read TGT_MAC
    do
        aireplay-ng --deauth 1 -c $TGT_MAC -a $1 $2 > /dev/null 2>&1
    done < $BLACKLIST_PATH
done