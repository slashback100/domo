#!/bin/bash
. /opt/domo/modules/functions.sh
exclude=light.l_buanderie,light.l_hall_ambiance,light.l_atelier_mel,light.l_cave_jardin,light.l_cave_technique,light.l_escalier_cave,light.l_grenier,light.l_atelier_mel_chauufage,light.l_bar,light.l_billard_chauffage_entree,light.l_billard_chauffage_entree_2,light.l_billard_chauffage_fond,light.l_cinema_chauffage,light.l_kicker,light.l_urinoir,light.l_billard,light.l_cinema_lampe
trap killSubProcess SIGINT SIGTERM
nbOfDays=7
lastweek=$(date +"%Y-%m-%dT%H:%M:%S.00" -d "- $nbOfDays days")
now=$(date +"%Y-%m-%dT%H:%M:%S.00")
date | grep CEST > /dev/null && offset=2 || offset=1 #2 hours in summer (CEST), 1 hour in winter (CET)
log(){
	#echo $*
	echo $@ >> /tmp/replay.log
	local a=1
}
itemHistory(){
	local entity="$1"
	k=$RANDOM
	log $k entity $entity
	log $k $(curl -s --insecure -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $token" "https://localhost:4294/api/history/period/$lastweek?end_time=$now&filter_entity_id=$entity")
	curl -s --insecure -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $token" "https://localhost:4294/api/history/period/$lastweek?end_time=$now&filter_entity_id=$entity" | jq -r --unbuffered '.[0][] | {last_changed,state}' 2>&1 | grep : | sed -En '/last_changed/ {N;s/\n// p}' | awk '{print $2,$4}' | cut -d'"' -f2,4 --output-delimiter=' ' | sort | while read event
	do
		log $k $event
		time=$(echo $event | awk '{print $1}')
		state=$(echo $event | awk '{print $2}')
		nowS=$(date +%s -d "- $nbOfDays days")
		time=$(date +%s -d "$time - $offset hours")
		#echo Entity $entity: state $state, now $nowS, time $time 1>&2
		while [ $time -gt $nowS ]
		do
			log $k Entity $entity: Sleeping for $((time-$nowS)) sec "(" $(((time-$nowS)/60)) " min or " $(((time-nowS)/3600))" hours)"
			sleep $((time-$nowS))
			nowS=$(date +%s -d "- $nbOfDays days")
		done
		# send event
		log $k Send item $entity to $state
		curl -s --insecure -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $token" -d '{"entity_id": "'$entity'"}'  https://localhost:4294/api/services/light/turn_$state > /dev/null
	done
	log $k done
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
		#pid=$!
	else
		log Skipping $item
	fi
done < <(curl -s --insecure -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $token"  https://localhost:4294/api/states | jq '.[].entity_id' | cut -d'"' -f2 | egrep '^light.')

wait #$pid # if no pid is given, it waits for all sub process end
# loop if activated more than 1 week
$0 $@
