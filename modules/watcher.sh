#!/bin/bash
. /opt/domo/modules/functions.sh
waitGivenMessage(){
    while read i
    do 
        return
    done < <($submit -v -t '#' | grep --line-buffered "^$1$")
}

waitForCallback(){
    # topci should be rceived
    local topic="$1"
    local tf=/tmp/tempFile$RANDOM
    #touch $tf
    if echo "/$topic/" > /dev/null | grep out
    then
        local pid=/tmp/pid$RANDOM
        #submit -t "callback" | egrep --line-buffered "^$topic$" > $tf &
        ( $submit -t "callback" & echo $! >&3 ) 3> $pid | grep --line-buffered "^$topic$" > $tf &
        local pid2=$!
        # autre solution
        
        #submit -t "callback" > >(grep --line-buffered "^$topic$" > $tf) &
        #pid=$!
        
        #local pid=$!
        sleep 5 #expect answer after max x second
        if [ $(cat $tf  | wc -l) -ge 1 ]
        then
            $publish -t log/debug/watchdog -m "Feedback received from command $topic"
        else
            $publish -t log/error/watchdog -m "No feedback from command $topic"
            # -> reset the arduino
          #  sudo service mqttToSerial_etage1a restart
        fi 
        #kill $pid > /dev/null 2>&1
        kill $(<$pid) > /dev/null 2>&1
        kill $pid2 > /dev/null 2>&1
        rm $tf
        rm $pid
    fi
}

sudo chmod 777 /tmp
# if received smt like etage_x/piece/type/id ON/OFF -> wait for a callback etage_x/piece/type/id
$submit -v -t 'cmd/#' | while read mess
do
    topic=$(echo $mess | awk '{print $1}')
    waitForCallback $topic &
done
