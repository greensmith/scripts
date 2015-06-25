#!/bin/bash
# check interface information
# if it should be up/down/disabled etc.
# we have a naming policy for our switch ports they are set to not_live if they are disabled (default)
# or set to the patchpanel/device using them if active
# this script check each port to make sure it has been described before being active
# $1 is host. add more $2 $3 etc for community or version (if  you need them)

IFS=$'\n'

INTERFACES=( $(snmpwalk -c public -v 2c -m IF-MIB -O qv $1 ifIndex) )
DESCRIPTIONS=( $(snmpwalk -c public -v 2c -m IF-MIB -O qv $1 ifDescr) )
ADMINSTATE=( $(snmpwalk -c public -v 2c -m IF-MIB -O qv $1 ifAdminStatus) )
OPSTATE=( $(snmpwalk -c public -v 2c -m IF-MIB -O qv $1 ifOperStatus) )
ALIASES=()
STATUS=0
STATUSMSG=""
PORTS_WARN=()
PORTS_ERR=()

#iter over each interface
for i in "${!INTERFACES[@]}"
do
 #get alias (ifAlias gives more interfaces than we have so can't walk)
 ALIASES+=("$(snmpget -v 2c -c public -m IF-MIB -O qv $1 ifAlias.${INTERFACES[$i]})")
 #echo "${INTERFACES[$i]} ${DESCRIPTIONS[$i]} ${ALIASES[$i]} ${ADMINSTATE[$i]} ${OPSTATE[$i]}"
 # check int status
 if [[ "${ALIASES[$i]}" =~ "not" ]] && [[ "${ADMINSTATE[$i]}" == "up" ]] && [[  "${OPSTATE[$i]}" == "down" ]]
  then
   #port is described as not live but is adminup
   PORTS_WARN+=("${DESCRIPTIONS[$i]}")
 elif [[ "${ALIASES[$i]}" =~ "not" ]] && [[ "${ADMINSTATE[$i]}" == "up" ]] && [[  "${OPSTATE[$i]}" == "up" ]]
  then
   #port is described as not live AND BEING USED
   PORTS_ERR+=("${DESCRIPTIONS[$i]}")
 fi
done

#count PORTS_WARN and PORTS_ERR to determine the return error code
#echo "${#PORTS_WARN[@]}"
#echo "${#PORTS_ERR[@]}"

if [[ "${#PORTS_WARN[@]}" -gt 0 ]]
 then
  #echo "some ports with warnings"
  STATUS=1
  STATUSMSG+="WARN: ${PORTS_WARN[@]} - enabled but not described!"
fi
if [[ "${#PORTS_ERR[@]}" -gt 0 ]]
 then
  #echo "some ports with errors"
  STATUS=2
  STATUSMSG+="CRIT: ${PORTS_ERR[@]} - LIVE but not described!"
fi

unset IFS

case $STATUS in
 0) echo "OK: no port issues"
    exit $STATUS
    ;;
 1) echo $STATUSMSG
    exit $STATUS
    ;;
 2) echo $STATUSMSG
    exit $STATUS
    ;;
esac

exit 0
