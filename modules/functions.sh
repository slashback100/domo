#!/bin/bash
. /opt/domo/modules/properties
killSubProcess(){
    pkill -g $$ 
}
fromTopicToName(){
    local topic="$1"
    local type="${2:-prettyName}"
    if [ "$type" = "prettyName" ]
    then
        out=$(grep "$topic": /etc/openhab2/items/*items | cut -d'"' -f2)
    else 
        out="type $type not known"
    fi
    echo $out
}
fromSwitchToTopic(){
    local switch="$1 " # add a space at the end (to avoid that switch1 selects switch12 
    out=$(grep "$switch" /etc/openhab2/items/*items | sed -E 's/^.*mqttbroker:(.*):state.*$/\1/')
    echo $out
}
publish="mosquitto_pub -u slashback -P nimda -h $mqttBroker"
submit="mosquitto_sub -u slashback -P nimda -h $mqttBroker"

