## 433 WiFiShield Application
The application must be run with root privileges!

The WiFiShield bash script requires that it work within its own directory and to have access to the following files:

- blacklist.txt: A simple list containing MAC addresses to be kept off the network. Formatted as lines of MAC address separated by newlines
- netscan.log: A cache for storing the output results of the Nmap network scan
- deauthBlacklist.sh: A helper shell script for the WiFiShield blacklisting feature. Do not run this script individually!

# Setup
1. Create a new directory and place the "WiFiShield.sh" and "deauthBlacklist.sh" scripts into it (the application generates several files on its own)
2. Run the "WiFiShield.sh" with root privileges (the script is not malicious, really!)
3. Navigate the application by inputting various values of numbers, using 0 to exit.
