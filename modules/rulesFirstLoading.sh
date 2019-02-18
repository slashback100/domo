#!/bin/bash
. /opt/domo/modules/functions.sh

pushButton(){
    $publish -t $topic -m ON
    sleep 0.1
    $publish -t $topic -m OFF
    sleep 0.1
}

# issues with switch that turns everything off (not real switch)
while read rules
do
    switch=$(echo $rules | awk '{print $1}')
    onOrOff=$(echo $rules | awk '{print $2}')
    topic=$(fromSwitchToTopic $switch)
    pushButton $topic # turn light on (or off)
    sleep 20 
    pushButton $topic # turn light off (or on)
done < <(cat /etc/openhab2/rules/*|grep 'changed to' | awk '{print $2,$5}')
$publish -t init/initializer/ready -m 'ready'
