#!/bin/bash
fifo=/tmp/androidFifo
rm $fifo 2> /dev/null
mkfifo $fifo 
chmod og+w $fifo
tail -f $fifo | ssh -p 8762 root@192.168.0.145
