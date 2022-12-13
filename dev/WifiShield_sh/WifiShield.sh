#!/usr/bin/bash

# Bash script for WifiShield Functionality
# 
# Network information gatherer:
#   - provide useful information about your router and device
#   - lists connected devices to network
#   - filters for actual user devices
#
# Shield
#   - reads blacklist and whitelist of MAC addresses
#   - continuously sends deauth packets to 
#

## Globals
WCARD_NAME=
GATEWAY=

## Main Script
main ()
{
    echo "Initializing script..."
    init
    printl
    echo -e "
                        ========================
                      <                          >
                    <      WiFi-Shield v0.0.1      >
                      <                          >
                        ========================
            \n\n\n\n\n\n"
    echo "Welcome! Select one of the following actions..."
    printl
    echo "[0] Exit  [1] Network Info Utility    [2] Shield Utility"
    printl
    getRouterinfo
}

## Network info functions:

# Gets basic information about network
getNetinfo() {
    echo "===================="
    echo     "Network Info"
    echo "===================="
    echo -en "Wireless Card:\t"
    echo $WCARD_NAME 
    echo -en "Gateway:\t"
    echo $GATEWAY
}

# Gets information about router
getRouterinfo() {
    echo "===================="
    echo     "Router Info"
    echo "===================="
    iwconfig
}

## Nmap utility

## Aircrack-ng utility

## Helper utility

# Initializes script variables
init () {
    WCARD_NAME=$(ip route | grep default | grep -oP '(?<=dev )\w+')
    GATEWAY=$(ip route | grep default | grep -oP '(?<=via )\w+.\w+.\w+.\w+')
}


printl () {
    echo -e "______________________________________________________________________________________" 
}

## Execute script
main