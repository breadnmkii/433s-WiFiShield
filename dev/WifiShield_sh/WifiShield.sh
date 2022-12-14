#!/bin/bash

# Bash script for WifiShield Functionality
# 
# Welcome Screen
# [0] Exit
# [1] Network Utility
# [2] Shield Utilty
#
# Network Utility
# [0] Back
# [1] Get Network info                  √
# [2] Get Router info                   √
# [3] Scan for hosts on network         √
# [4] Scan IP                           √    
# [5] Scanlog Search
# [6] Resolve Hostname > IP
# [7] Resolve IP > MAC

# Shield Utility (WARN: entering shield utility disables your wireless connection!!!)
# READ: Confirm? [Y\n]
#  [0] Back
#  [1] Run Blacklist    (simple deauth packet stream)
#  [2] Run Whitelist    (airodump, deauth any device not matching whitelist mac)
#

## Constants
SCANLOG_PATH="netscan.log"

## Globals
sys_init="error!"
SSID=
WLAN_NAME=
WLAN_MON=
GATEWAY=

## Main Script
main ()
{
    init
    printl
    echo -e "
                        ========================
                      <                          >
                    <      WiFi-Shield v0.0.1      >
                      <                          >
                        ========================

System: $sys_init
Shielding: ($SSID)
            \n\n\n\n"
    echo "Welcome! Select one of the following actions..."
    printl
    echo "[0] Exit  [1] Network Info Utility    [2] Shield Utility"
    printl

    searchScanlog
    
}

## Network info functions:
# Gets basic information about network
getNetinfo() {
    echo "===================="
    echo     "Network Info"
    echo "===================="
    echo -en "Wireless Card:\t"
    echo $WLAN_NAME 
    echo -en "Gateway:\t"
    echo $GATEWAY
    echo -e "Metadata:"
    echo -e $(ifconfig $WNAME_CARD)
}

# Gets information about router
getRouterinfo() {
    echo "===================="
    echo     "Router Info"
    echo "===================="
    iwconfig $WLAN_NAME
}

## Nmap utility
# Scans network the user is connected to
scanNetwork() {
    echo -n "Range to scan (e.g. 0-31, or empty for 0-255): "
    read NET_RANGE
    if [ -z $NET_RANGE ]
    then
	    echo "Scanning ${GATEWAY_24}0-255...";
        nmap -sS "${GATEWAY_24}0/24" > $SCANLOG_PATH
    else
        echo "Scanning ${GATEWAY_24}${NET_RANGE}...";
        nmap -sS "${GATEWAY_24}${NET_RANGE}" > $SCANLOG_PATH
    fi
	echo "Scanning complete! Check netscan.log or use Scanlog Search"
}

# Scans specified ip
scanIP() {
    echo -n "IP to port scan: "
    read NET_SCAN
    nmap -Pn $NET_SCAN
}

# Simple search ScanLog for grep matches
searchScanlog() {
    echo -n "Enter key searchterm: "
    read KEY_SEARCH
    cat $SCANLOG_PATH | grep -A4 $KEY_SEARCH
}

## Aircrack-ng utility

## Helper utility

# Initializes script variables
init () {
    # Check if ran as root
    if [ "$EUID" -ne 0 ]
    then 
        echo "run as root"
        exit
    fi
    
    # Check dependencies
    if ! command -v ifconfig &> /dev/null
    then
        echo "ifconfig command must be installed!" 
        exit
    fi
    if ! command -v iwconfig &> /dev/null
    then
        echo "iwconfig command must be installed!" 
        exit
    fi
    if ! command -v ip &> /dev/null
    then
        echo "ip command must be installed!" 
        exit
    fi
    if ! command -v airmon-ng &> /dev/null || ! command -v airodump-ng &> /dev/null || ! command -v aireplay-ng &> /dev/null
    then
        echo "Aircrack tools must be installed!" 
        exit
    fi

    SSID=$(iwgetid -r)
    WLAN_NAME=$(iwgetid | grep -o '^.* ' | xargs)
    WLAN_MON="${WLAN_NAME}mon"
    GATEWAY=$(ip route | grep default | grep $WLAN_NAME | grep -oP '(?<=via )\w+.\w+.\w+.\w+')
    GATEWAY_24=$(ip route | grep default | grep $WLAN_NAME | grep -oP '(?<=via )\w+.\w+.\w+.')

    sys_init="nominal"
}


printl () {
    echo -e "______________________________________________________________________________________" 
}

## Execute script
main
