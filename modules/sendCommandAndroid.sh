#!/bin/bash
fifo=/tmp/androidFifo
echo $1
if [ ${1:-void} = volminus ]
then
	echo "input keyevent 25" >> $fifo
elif [ ${1:-void} = volplus ]
then
	echo "input keyevent 24" >> $fifo
else
	echo "Command not known"
fi

