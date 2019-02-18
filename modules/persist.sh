#!/bin/bash
. /opt/domo/modules/properties
mosquitto_sub -h $mqttBroker -u slashback -P nimda -v -t 'cmd/#' | while read l
do
    topic=$(echo $l | awk '{print $1}')
    mess=${l/$topic }
    if [ ${topic/out} != $topic ] # if an output
    then
        mosquitto_pub -h $mqttBroker -u slashback -P nimda -r -t "persistence/$topic" -m "$mess"
    fi
done

