#!/bin/bash
. /opt/domo/modules/properties
killSubProcess(){
    pkill -g $$ 
}
publish="mosquitto_pub -u slashback -P $password -h $mqttBroker"
submit="mosquitto_sub -u slashback -P $password -h $mqttBroker"

