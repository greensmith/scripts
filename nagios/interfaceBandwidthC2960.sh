#!/bin/bash
# Nagios script for calculating interface bandwidth on a Cisco C2960 port.
# Should work on other models but not tested
#
# $1 is host, $2 is interface id, $3 is previous service output
#
# e.g. './interfaceBandwidthC2960.sh 10.10.10.1 10102' will output bandwidth information for port 2 on switch with
# that ip address. There is no parameter for snmp community or verson but you can either add them
# or modify the hard coded values if you like.
#
# Nagios uses this in a check command. like such
# $USER1$/interfaceBandwidthC2960.sh "$HOSTNAME$" "$ARG1$" "$SERVICEOUTPUT$"
# host or service will call check-commmand-named!portnumber
# and script will output
# '<values> | <perf data>' and exit with 0 (ok) 

if [ -z "$1" ]
  then
    echo "No argument supplied"
    exit 0
fi
if [ -z "$2" ]
  then
    echo "No argument supplied"
    exit 0
fi

if [ -z "$3" ]
#this will usually be triggered on first run when no previous data exist
        then
                currentinput=$(snmpget -v 2c -c public -mIF-MIB -O qv $1 ifInOctets.$2)
                currentoutput=$(snmpget -v 2c -c public -mIF-MIB -O qv $1 ifOutOctets.$2)
                echo "inputocts=$currentinput,outputocts=$currentoutput,inputbits=0,outputbits=0,time=$(date +%s) | input=0; output=0; total=0"
                exit 0
fi

currentinput=$(snmpget -v 2c -c public -mIF-MIB -O qv $1 ifInOctets.$2)
currentoutput=$(snmpget -v 2c -c public -mIF-MIB -O qv $1 ifOutOctets.$2)

unixtime=$(date +%s)
maxvalue="4294967295"

IFS=',' read -a oldioarray <<< "$3"

oldinput=$(echo ${oldioarray[0]} | cut -d'=' -f2)
oldoutput=$(echo ${oldioarray[1]} | cut -d'=' -f2)
oldunixtime=$(echo ${oldioarray[4]} | cut -d'=' -f2)

timediff=$(($unixtime-$oldunixtime))


if [ $currentinput -lt $oldinput ]
 then
  $currentinput=$(( $currentinput + $maxvalue ))
fi

if [ $currentoutput -lt $oldoutput ]
 then
  $currentoutput=$(( $currentoutput + $maxvalue ))
fi

inbits=$(( ($currentinput - $oldinput) * 8 / $timediff ))

# sanity check stop negative values -  this needs fixing!!!!!!!!
if [ $inbits -lt 0 ]
 then
  inbits=0
fi

outbits=$(( ($currentoutput - $oldoutput) * 8 / $timediff ))

# sanity check stop negative values -  this needs fixing!!!!!!!!
if [ $outbits -lt 0 ]
 then
  outbits=0
fi

total=$(( $inbits + $outbits ))

# finally, echo back to nagios.
echo "inputocts=$currentinput,outputocts=$currentoutput,inputbits=$inbits,outputbits=$outbits,time=$unixtime | input=$inbits; output=$outbits; total=$total"
exit 0
