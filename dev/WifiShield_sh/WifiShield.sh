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
# [5] Scanlog Search                    √
# [6] Resolve Hostname > IP             √
# [7] Resolve IP > MAC                  √

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
usr_input=""
SSID=
WLAN_NAME=
WLAN_MON=
WLAN_MAC=
WLAN_CHN=
GATEWAY=

## Main Script
main ()
{
    #init

    while [[ $usr_input != "0" ]]
    do  
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
        printUI "[0] Exit\t[1] Network Info Utility\t[2] Shield Utility"

        if [[ $usr_input == "1" ]]
        then
            # Network Utility
            while [[ $usr_input != "0" ]]
            do
                printUI "
                        [0] Back\t
                        [1] Get Network Info\t
                        [2] Get Router Info\t\n
                        [3] Scan for Hosts on Network\t
                        [4] Scan IP\t
                        [5] Scanlog Search\t\n
                        [6] Resolve Hostname > IP\t
                        [7] Resolve IP > MAC\t
                        "
                case $usr_input in

                    "1")
                        echo "1"
                    ;;
                    "2")
                        echo "2"
                    ;;
                    "3")
                        echo "3"
                    ;;
                    "4")
                        echo "4"
                    ;;
                    "5")
                        echo "5"
                    ;;
                    "6")
                        echo "6"
                    ;;
                    "7")
                        echo "7"
                    ;;
            done
            usr_input=""
        fi

        if [[ $usr_input == "2" ]]
        then
            # Shield Utility
            echo "WARNING: Shield Utility disables WiFi!"
            echo "Continue? [Y/n]: "
            read usr_input
            if [[ $usr_input == "Y" || $usr_input == "y" ]]
            then
                while [[ $usr_input != "0" ]]
                do
                    printUI "[0] Back\t[1]Run Blacklist\t[2]Run Whitelist"
                done
            fi
            usr_input=""
        fi


    done
    
    echo "Shield: OFF"
    echo "Goodbye!"
    
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
    echo -e $(ip link show dev $WLAN_NAME)
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

# Simple search ScanLog for sed matches
searchScanlog() {
    echo -n "Enter key searchterm: "
    read KEY_SEARCH
    sed -n "/${KEY_SEARCH}/,/^$/p" "$SCANLOG_PATH"
}

# resolve hostname to IP
HOSTtoIP() {
    echo -n "Enter hostname: "
    read HOSTNAME
    echo "Resolving... "
    nslookup $HOSTNAME
}

# resolve IP to MAC
IPtoMAC() {
    echo -n "Enter IP address: "
    read IP_ADDR
    echo "Resolving..."
    MAC_ADDR=$(arp -a $IP_ADDR | grep -oP '(?<=at )\w+:\w+:\w+:\w+:\w+:\w+')
    echo "$IP_ADDR > $MAC_ADDR"

}

## Aircrack-ng utility

## Helper utility
printl () {
    echo -e "______________________________________________________________________________________" 
}

printUI () {
    printl
    echo -e $1
    printl
    echo -n "Select: "
    read usr_input
}


## Program initializer
init () {
    # Check if ran as root
    if [ "$EUID" -ne 0 ]
    then 
        echo "Run as root"
        exit
    fi
    
    # Check dependencies
    if ! command -v ip &> /dev/null
    then
        echo "ip command must be available!" 
        exit
    fi
    if ! command -v iw &> /dev/null || ! command -v iwgetid &> /dev/null || ! command -v iwconfig &> /dev/null
    then
        echo "iw command must be available!" 
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
    WLAN_MAC=$(iwgetid -ar)
    WLAN_CHN=$(iw)
    GATEWAY=$(ip route | grep default | grep $WLAN_NAME | grep -oP '(?<=via )\w+.\w+.\w+.\w+')
    GATEWAY_24=$(ip route | grep default | grep $WLAN_NAME | grep -oP '(?<=via )\w+.\w+.\w+.')

    sys_init="nominal"
}


## Execute script
main
