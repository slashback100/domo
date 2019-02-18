#!/bin/bash
. /opt/domo/modules/functions.sh
exec >> /tmp/domo.log
(
$submit -v -t 'log/#' | while read i
do
    echo $(date "+%Y%m%d %H:%M:%S.%N") $i
done
) &
exec >> /tmp/allDomo.log
$submit -v -t '#' | while read i
do
    echo $(date "+%Y%m%d %H:%M:%S.%N") $i
done
