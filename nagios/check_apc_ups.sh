#!/bin/bash
# check on APC UPS system - requires POWERNET-MIB
# used with APC Symmetra 40k
# $1 is apc controller. we use public as community but change as needed.

# get snmp valuse

UPS_CAPACITY=$(snmpget -c public -v 1 -m PowerNet-MIB -O qv $1 upsAdvBatteryCapacity.0)
UPS_TEMPERATURE=$(snmpget -c public -v 1 -m PowerNet-MIB -O qv $1 upsAdvBatteryTemperature.0)
UPS_BATTERIES=$(snmpget -c public -v 1 -m PowerNet-MIB -O qv $1 upsAdvBatteryNumOfBattPacks.0)
UPS_BADBATTERIES=$(snmpget -c public -v 1 -m PowerNet-MIB -O qv $1 upsAdvBatteryNumOfBadBattPacks.0)
UPS_LASTTEST=$(snmpget -c public -v 1 -m PowerNet-MIB -O qv $1 upsAdvTestLastDiagnosticsDate.0)
UPS_LASTTEST=$(echo "$UPS_LASTTEST" | sed -e 's/^"//'  -e 's/"$//')
UPS_LASTTESTDATE=$(date --utc --date $UPS_LASTTEST +%s )
UPS_LASTTESTRESULT=$(snmpget -c public -v 1 -m PowerNet-MIB -O qv $1 upsAdvTestDiagnosticsResults.0)

STATUSINFO=""
STATUS=0

CURRENTDATE=$(date +%s)

if [[ "$UPS_CAPACITY" -lt "100" ]]; then
 STATUS=2
 STATUSINFO+="CAPACITY ERROR "
fi

if [[ "$UPS_TEMPERATURE" -gt  "35" ]]; then
 STATUS=2
 STATUSINFO+="TEMPERATURE ERROR "
fi


if [[ "$UPS_BADBATTERIES" > "0" ]]; then
 STATUS=2
 STATUSINFO+="BAD BATTERY ERROR "
fi

if [[ "$CURRENTDATE - $UPS_LASTTESTDATE" -gt  "1209600" ]]; then
 STATUSINFO+="MORE THAN WEEK SINCE LAST TEST ERROR "
 if [ STATUS!=2 ]; then
  STATUS=1
 fi
fi

if [[ "$UPS_LASTTESTRESULT" != "ok" ]]; then
 STATUS=2
 STATUSINFO+="LAST RESULT ERROR "
fi

echo "$STATUSINFO | TEMP=$UPS_TEMPERATURE;"
exit $STATUS
