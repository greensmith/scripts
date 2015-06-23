#!/bin/bash
# check status of dell md3000 storage array
# change /opt/dell/.... to folder containing SMcli
# input from nagios is ip address of storage array
# checks with regex for status.

Client="/opt/dell/mdstoragemanager/client/SMcli"

#run check status
Status=$($Client $1 -S -c "show storageArray healthStatus;" -quick)


ErrCode=2

if [[ $Status =~ "synchronization" ]]
 then
  ErrCode=1
fi

if [[ $Status =~ "optimal" ]]
 then
  ErrCode=0
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
