#!/bin/bash
. /opt/domo/modules/functions.sh
facadeAvant="md/etage1a/out/12"
function isDark(){
    local json=`wget -q -O - 'http://api.openweathermap.org/data/2.5/weather?q=Amay,be&units=metric&APPID=ddcf9bc810a94458cb877f54dbb9ffa5'`
    local sunrise=`echo $json|sed 's/^.*"sunrise":\([0-9]*\).*$/\1/g'`
    local sunset=`echo $json|sed 's/^.*"sunset":\([0-9]*\).*$/\1/g'`
    local h=`date +%s`
    #h=1478523600
    if [ $h -gt $sunset ] || [ $h -lt $sunrise ]
    then
        echo 1
    else
        echo 0
    fi
}    
function turnOff(){
    sleep 300
    $publish -t 'log/info/locationWatcher' -m 'Turning off ext front light'
    $publish -t $facadeAvant
}
function atLeastOneLightOn(){
    coproc MOS { $submit -v -t "#" ;}
    sleep 0.1
    $publish -t 'log/debug/locationWatcher' -m 'to_get_out_of_coproc'
    local itemsName="" 
    local returnCode=1
    while read itemStatus
    do
        [ "${itemStatus/to_get_out_of_coproc}" != "$itemStatus" ] && break
        message=${itemStatus/* }
        if [ a$message = aON ] && [ "${itemStatus/out}" != "$itemStatus" ]
        then
            local topic=${itemStatus/ $message}
            topic=${topic/persistence\/}
            returnCode=0 
            local name=$(fromTopicToName "$topic" prettyName)
            [ ${itemsName:-void} != void ] && itemsName="$itemsName, "
            itemsName="$itemsName $name"
        fi
    done <&${MOS[0]}
    pkill -P $MOS_PID
    echo $itemsName
    return $returnCode
}

sudo chmod 777 /tmp
$submit -t 'cmd/location/#' | while read mess
do
    # 20180924 16:32:26 Vermeg enter|leave
    location=$(echo "$mess" | awk '{print $3}')
    event=$(echo "$mess" | awk '{print $4}')
    if [ "a$location" = "aAbbaye" ] && [ a$event = aenter ] && [ $(isDark) -eq 1 ]
    then
        $publish -t 'log/info/locationWatcher' -m 'Turning on ext front light'
        $publish -t "$facadeAvant" -m ON
        turnOff &       
    fi
    if [ "a$location" = "aAbbaye" ] && [ a$event = aleave ]
    then
        whatson=$(atLeastOneLightOn)
        if [ $? -eq 0 ]
        then
            [ "a${whatson/,}" != "a$whatson" ] && txt="Des lampes sont restées allumées :" || txt="Une lampe est restée allumée :"
            /opt/domo/tools/sendiphoneNotif "$txt $whatson"
#        else
#            /opt/domo/tools/sendiphoneNotif "Toutes les lampes sont éteintes"
        fi
    fi
done
