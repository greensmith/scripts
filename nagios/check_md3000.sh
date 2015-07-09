#!/bin/bash
# check status of dell md3000 storage array
# change /opt/dell/.... to folder containing SMcli
# input from nagios is ip address of storage array controllers
# checks with regex for status.
# use two ips $1 and $2
Client="/opt/dell/mdstoragemanager/client/SMcli"

#run check status
Status=""
Status1=$($Client $1 -S -c "show storageArray healthStatus;" -quick)
Status2=$($Client $2 -S -c "show storageArray healthStatus;" -quick)


ErrCode=0

if [[ $Status1 =~ "synchronization" ]]
 then
  #run sync
  $Client $1 -S -c "set storageArray time;" -quick
  Status1=$($Client $1 -S -c "show storageArray healthStatus;" -quick)
fi

if [[ $Status2 =~ "synchronization" ]]
 then
  #run sync
  $Client $2 -S -c "set storageArray time;" -quick
  Status2=$($Client $2 -S -c "show storageArray healthStatus;" -quick)
fi


if [[ ! $Status1 =~ "optimal" ]] || [[ ! $Status2 =~ "optimal" ]]
 then
  ErrCode=2
  Status="$Status1 $Status2"
else
 Status="$Status1"
fi



case $ErrCode in
 0) echo $Status
    exit $ErrCode
    ;;
 1) echo $Status
    exit $ErrCode
    ;;
 2) echo $Status
    exit $ErrCode
    ;;
esac
