#!/bin/bash
. /opt/domo/modules/functions.sh
exclude=light.l_buanderie,light.l_hall_ambiance
trap killSubProcess SIGINT SIGTERM
lastweek=$(date +"%Y-%m-%dT%H:%M:%S.00" -d "- 7 week")
now=$(date +"%Y-%m-%dT%H:%M:%S.00")
itemHistory(){
	entity="$1"
	curl -s -X GET -H "Content-Type: application/json" -H "X-HA-Access: $password" "http://localhost:8123/api/history/period/$lastweek?end_time=$now&filter_entity_id=$entity"| jq -r --unbuffered '.[0][] | {last_changed,state}' | grep : | sed -En '/last_changed/ {N;s/\n// p}' | awk '{print $2,$4}' | cut -d'"' -f2,4 --output-delimiter=' ' | sort | while read event
	do
		time=$(echo $event | awk '{print $1}')
		state=$(echo $event | awk '{print $2}')
		now=$(date +%s -d "- 1 week")
		time=$(date +%s -d "$time")
		while [ $time -gt $now ]
		do
			echo sleeping for $((time-$now)) sec
			sleep $((time-$now))
			now=$(date +%s -d "- 1 week")
		done
		# send event
		echo send item $entity to $state
		curl -s -X POST -H "Content-Type: application/json" -H "X-HA-Access: $password" -d '{"entity_id": "'$entity'"}'  http://localhost:8123/api/services/light/turn_$state > /dev/null
	done
}
isExcluded(){
	local it=",${1},"
	local lst=",${exclude},"
	[[ $lst =~ $it ]]
	return $?
}
while read item
do
	if ! isExcluded "$item"
	then
		itemHistory "$item" &
		pid=$!
	else
		echo Skipping $item
	fi
done < <(curl -s -X GET -H "Content-Type: application/json" -H "X-HA-Access: $password"  http://localhost:8123/api/states | jq '.[].entity_id' | cut -d'"' -f2 | egrep '^light.')

wait $pid
# loop if activated more than 1 week
$0 $@
