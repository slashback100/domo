#!/bin/bash
. /opt/domo/modules/functions.sh

vermegLat=50.8462
vermegLon=4.3688
cracLat=50.4565
cracLon=4.8038
homeLat=50.5723
homeLon=5.3046
radius=0.001

isIn(){
    local lat=$3
    local lon=$4
    local zoneLat=$1
    local zoneLon=$2
    # lat > zoneLat-radius    
    # & lat < zoneLat+radius
    
    #echo "$lat>$zoneLat-$radius" | bc 1>&2
    #echo "$lat<$zoneLat+$radius" | bc 1>&2
    #echo "$lon>$zoneLon-$radius" | bc 1>&2
    #echo "$lon<$zoneLon+$radius" | bc 1>&2

    if [ $(echo "$lat>$zoneLat-$radius" | bc) -eq 1 ] && [ $(echo "$lat<$zoneLat+$radius" | bc) -eq 1 ] && [ $(echo "$lon>$zoneLon-$radius" | bc) -eq 1 ] && [ $(echo "$lon<$zoneLon+$radius" | bc) -eq 1 ]
    then
        return 0
    else
        return 1
    fi
}
getLocation(){
    local lat=$1
    local lon=$2
    #echo $lat $lon 1>&2
    if isIn $homeLat $homeLon $lat $lon
    then
        echo home
    elif isIn $vermegLat $vermegLon $lat $lon
    then
        echo vermeg
    elif isIn $cracLat $cracLon $lat $lon
    then
        echo crac
    else
        echo unknown
    fi
}
trackChrisiPhone(){
    $submit -t 'owntracks/slashback/#' | while read json
    do
        local type=$(echo $json | jq -r '._type')
        if [ $type = transition ]
        then
            local lat=$(echo $json | jq -r '.lat')
            local lon=$(echo $json | jq -r '.lon')
            local who=$(echo $json | jq -r '.tid')
            local ts=$(echo $json | jq -r '.tst')
            #local region=$(echo $json | jq -r '.inregions[0]')
            local region=$(echo $json | jq -r '.desc')
            local enterOrLeave=$(echo $json | jq -r '.event') # enter or leave
            region=${region:-unknown}
            ts=$(date  "+%Y%m%d %H:%M:%S" -d @$ts)
            [ $who = IS ] && who=chris || who=mel
            #local location=$(getLocation $lat $lon)
            local location=$region
            echo "$ts: $who is at $location"
            $publish -t cmd/location/$who -m "$ts $location $enterOrLeave"
        fi
    done
}
trackChrisiPhone
