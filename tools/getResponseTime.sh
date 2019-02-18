#!/bin/bash
#compute time between input and callback of following oug
grep -Pzo "(?s)^\N*/in/\N*ON\N*.\N*.\N*.\N*callback\N*/out/"  /tmp/allDomo.log  | egrep -v '^([^c]|c[^a]|ca[^l])*out' | grep -v 'in.*OFF' | sed -nE '/in/ {N;s/\n/ / p}' | awk '{print $2,$6}' |  while read i;do in=$(echo $i |cut -d' ' -f1);in=$(date +%s%N -d "$in");out=$(echo $i | cut -d' ' -f2);out=$(date +%s%N -d "$out");echo -n "$i: "; echo "($out-$in)/1000000" | bc ;done
