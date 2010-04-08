#!/bin/bash

FILTER="false"
#FILTER="true"


if [ ! $FILTER = "true" ]; then
    while read FILE; do
        echo $FILE
    done
else
    while read FILE; do
        WAITING_LN=`cat $FILE | grep -n 'Waiting after end of match' | awk -F: '{print $1}'`
        DISCONNECTED_LN=`cat $FILE | grep -n 'A player disconnected' | awk -F: '{print $1}' | head -1`

        if [ $DISCONNECTED_LN -gt $WAITING_LN ]; then
            echo $FILE
        fi
    done
fi
