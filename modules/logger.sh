#!/bin/bash
. /opt/domo/modules/functions.sh
#exec >> /tmp/domo.log
#(
#$submit -v -t 'log/#' | while read i
#do
#    echo $(date "+%Y%m%d %H:%M:%S.%N") $i
#done
#) &
exec >> /tmp/allDomo.log
$submit -v -t '#' | while read i
do
    if [[ "$i" =~ cmd/etage../out/[0-9]+ ]]
    then
	pattern=$(echo $i | sed -E 's#^.*(cmd/etage../out/[0-9]+).*$#\1#')
        pretty=$(cat /home/homeassistant/.homeassistant/light/*.yaml | grep -B 3 "$pattern" | grep name | head -n1 | cut -d'"' -f2)
	echo $(date "+%Y%m%d %H:%M:%S.%N") "$i ($pretty)"
    elif [[ "$i" =~ cmd/etage../in/[0-9]+ ]]
    then
	pattern=$(echo $i | sed -E 's#^.*(cmd/etage../in/[0-9]+).*$#\1#')
	pretty=$(grep "$pattern" -B 5 /home/homeassistant/.homeassistant/automation/*yaml | grep alias | cut -d':' -f2 | sed -E 's/^ *(.*)$/\1/')
	echo $(date "+%Y%m%d %H:%M:%S.%N") "$i ($pretty)"
    else
	echo $(date "+%Y%m%d %H:%M:%S.%N") $i
    fi
done
