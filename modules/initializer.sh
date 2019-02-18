#!/bin/bash
. /opt/domo/modules/functions.sh
# the following is needed if the current initializer is launched after the arduino start. 
# indeed in that scenario the 'ready' message from the arduino won't be received, so we force a 
# initialization here 
(sleep 5 ; $publish -t init/initializer/ready -m 'ready') &
$submit -v -t 'init/#' | while read l
do
    topic=$(echo $l | awk '{print $1}')
    #mess=${l/$topic }
    if [ ${topic/ready} != $topic ] # arduino is ready, send him the outputs statuses
    then
        arduinoId=${topic/init\/}
        arduinoId=${arduinoId/\/ready}
        echo $arduinoId
        coproc MOS { $submit -v -t "#" ;}   
        sleep 0.1
        $publish -t 'log/debug/initializer' -m 'to_get_out_of_coproc'
        while read itemStatus
        do
            echo $itemStatus
            if [ "${itemStatus/to_get_out_of_coproc}" != "$itemStatus" ]
            then
               break # -> we are done treating interresting message, it is done 
            else
               topic=${itemStatus/ *}
               topic=${topic/persistence\/}
               message=${itemStatus/* }
               $publish -t "$topic" -m "$message"
            fi
        done <&${MOS[0]}
        pkill -P $MOS_PID
    fi
done

