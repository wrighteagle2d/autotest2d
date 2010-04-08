#!/bin/bash

FILTER="false"
#FILTER="true"

while read FILE; do
    if [ ! $FILTER = "true" ]; then
        echo $FILE
        continue
    fi

    WAITING_LN=`cat $FILE | grep -n 'Waiting after end of match' | awk -F: '{print $1}'`
    DISCONNECTED_LN=`cat $FILE | grep -n 'A player disconnected' | awk -F: '{print $1}' | head -1`

    if [ $DISCONNECTED_LN -gt $WAITING_LN ]; then
        echo $FILE
    fi
done
