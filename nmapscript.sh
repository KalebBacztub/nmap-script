#!/bin/bash

echo -e "\n$(figlet -f slant 'NMAP Script')"


echo "Created By Kaleb Bacztub - For TCMs PJPT"
echo " "
echo "Check the exclude.txt"
echo " "


SUBNET=$1
EXCLUDE_FILE="exclude.txt"
XML_OUTPUT="nmap_output.xml"
HTML_OUTPUT="nmap_output.html"

if [ -z "$SUBNET" ]; then
    echo "Usage: $0 <subnet> (e.g., 192.168.1.0/24)"
    exit 1
fi

echo "[*] Performing quick scan on $SUBNET..."
nmap -sn $SUBNET | grep "Nmap scan report for" | awk '{print $5}' > temp_targets.txt

# Exclude specific IPs if exclude.txt exists
if [ -f "$EXCLUDE_FILE" ]; then
    grep -v -x -f "$EXCLUDE_FILE" temp_targets.txt > targets.txt
else
    mv temp_targets.txt targets.txt
fi

if [ ! -s targets.txt ]; then
    echo "[-] No live hosts found after exclusions."
    exit 1
fi

echo "[+] Live hosts saved to targets.txt"

echo "[*] Performing detailed scan on live hosts..."
> detailed_target_scan.txt
nmap -A -p- -T4 -iL targets.txt -oX $XML_OUTPUT | tee -a detailed_target_scan.txt

echo "[+] Detailed scan results saved to detailed_target_scan.txt and $XML_OUTPUT"

echo "[*] Converting XML to HTML..."
xsltproc $XML_OUTPUT -o $HTML_OUTPUT

echo "[+] HTML report saved as $HTML_OUTPUT"
