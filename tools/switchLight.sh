#!/bin/bash
. ../modules/properties
light=light."$1"
action="$2"
curl -s -X POST -H "Content-Type: application/json" -H "X-HA-Access: $apiPassword" -d '{"entity_id": "'$light'"}'  "http://localhost:8123/api/services/light/turn_$action" > /dev/null
