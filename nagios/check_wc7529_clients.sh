#!/bin/bash
# get number of wireless clients per SSID from NetGear WC7520
# $1 is WC7520 ip address -  add $2 or $3 to community and version if needed

WCLIENTSSID=( $(snmpwalk -c public -v 2c -m WC7520-MIB -O qv $1 wcClientSsid) )

# list your SSIDS here (edit these as needed)
declare -A SSIDS

SSIDS[UserSSID]=$(grep -o UserSSID <<< ${WCLIENTSSID[@]} | wc -l)
SSIDS[GuesSSID]=$(grep -o GuestSSID <<< ${WCLIENTSSID[@]} | wc -l)
SSIDS[OtherSSID]=$(grep -o OtherSSID <<< ${WCLIENTSSID[@]} | wc -l)

STR=""
STRPERF="Total=${#WCLIENTSSID[@]}; "
for i in "${!SSIDS[@]}"
do
  STR+=", $i(${SSIDS[$i]})"
  STRPERF+="$i=${SSIDS[$i]}; "
done

echo "There are ${#WCLIENTSSID[@]} clients on the Wireless Network$STR | $STRPERF"
exit 0
