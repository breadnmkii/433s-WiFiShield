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
#  [2] Monitor Network
#  [3] Deauth MAC
#

## Constants
SCANLOG_PATH="netscan.log"
BLACKLIST_PATH="blacklist.txt"

## Globals
sys_init="nominal"
sys_errors=""
usr_input=""
SSID=
WLAN_NAME=
WLAN_MAC=
WLAN_CHN=
GATEWAY=

## Main Script
main ()
{
    init

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
Errors: $sys_errors
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
                    "0")
                        echo "Returning to main menu"
                    ;;
                    "1")
                        getNetinfo
                    ;;
                    "2")
                        getRouterinfo
                    ;;
                    "3")
                        scanNetwork
                    ;;
                    "4")
                        scanIP
                    ;;
                    "5")
                        searchScanlog
                    ;;
                    "6")
                        HOSTtoIP
                    ;;
                    "7")
                        IPtoMAC
                    ;;
                        *) echo "unrecognized action"
                    ;;
                esac
            done
            usr_input=""
        fi

        if [[ $usr_input == "2" ]]
        then
            # Shield Utility
            echo "WARNING: Air Monitor disables WiFi!"
            echo "Continue? [Y/n]: "
            read usr_input
            if [[ $usr_input == "Y" || $usr_input == "y" ]]
            then
                echo "Putting wireless interface into monitor mode..."
                airmon-ng start $WLAN_NAME
                WLAN_NAME=$(iwgetid | grep -o '^.* ' | xargs)

                while [[ $usr_input != "0" ]]
                do
                    printUI "[0] Back\t[1] Run Blacklist\t[2] Deauth Mac\t[3] Air-Monitor"
                    case $usr_input in
                    "0")
                        echo "Returning to main menu"
                    ;;
                    "1")
                        runBlacklist
                    ;;
                    "2")
                        deauthMAC
                    ;;
                    "3")
                        airMonitor
                    ;;
                    *) 
                        echo "unrecognized action"
                    ;;
                    esac
                done
                usr_input=""

                echo "Exiting monitor mode..."
                airmon-ng stop $WLAN_NAME
                WLAN_NAME=$(iwgetid | grep -o '^.* ' | xargs)
            else
                echo "Cancelling Shield Utility..."
            fi
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
    echo -en "WLAN Interface:\t"
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
    iw dev $WLAN_NAME info
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
    echo -n "IP to aggressive scan: "
    read NET_SCAN
    nmap -A -T4 $NET_SCAN
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
# Spawns new bash window to deauth MAC addresses listed in "blacklist.txt" file
runBlacklist () {
    ./deauthBlacklist.sh $WLAN_MAC $WLAN_NAME
}

# Enables monitoring of wireless traffic
airMonitor() {
    airodump-ng $WLAN_NAME --bssid $WLAN_MAC --channel $WLAN_CHN
}

# Manual deauthentication of device given MAC address
deauthMAC() {
    echo -n "Target MAC: "
    read TGT_MAC
    echo "aireplay-ng --deauth 1 -c $TGT_MAC -a $WLAN_MAC $WLAN_NAME"
    aireplay-ng --deauth 1 -c $TGT_MAC -a $WLAN_MAC $WLAN_NAME
}

## Helper utility
printl () {
    echo -e "______________________________________________________________________________________" 
}

printUI () {
    echo -e "\n\n"
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
        sys_init="error!"
        sys_errors="${sys_errors}ip cmd error! "
    fi
    if ! command -v iw &> /dev/null || ! command -v iwgetid &> /dev/null || ! command -v iwconfig &> /dev/null
    then
        echo "iw command must be available!" 
        sys_init="error!"
        sys_errors="${sys_errors}iw cmd error! "
    fi
    if ! command -v airmon-ng &> /dev/null || ! command -v airodump-ng &> /dev/null || ! command -v aireplay-ng &> /dev/null
    then
        echo "Aircrack tools must be installed!" 
        sys_init="error!"
        sys_errors="${sys_errors}aircrack cmd error! "
    fi
    if ! command -v nmap &> /dev/null
    then
        echo "nmap tools must be installed!"
        sys_init="error!"
        sys_errors="${sys_errors}nmap cmd error! "
    fi
    
    if [[ $sys_init == "nominal" ]]
    then
        sys_errors="none"
    fi

    # Initialize globals
    SSID=$(iwgetid -r)
    WLAN_NAME=$(iwgetid | grep -o '^.* ' | xargs)
    WLAN_MAC=$(iwgetid -ar)
    WLAN_CHN=$(iw dev $WLAN_NAME info | grep -oP '(?<=channel )\d+')
    GATEWAY=$(ip route | grep default | grep $WLAN_NAME | grep -oP '(?<=via )\w+.\w+.\w+.\w+')
    GATEWAY_24=$(ip route | grep default | grep $WLAN_NAME | grep -oP '(?<=via )\w+.\w+.\w+.')

    echo -e "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
   
}


## Execute script
main
