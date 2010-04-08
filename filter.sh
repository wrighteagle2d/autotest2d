#!/bin/bash

FILTER="true"
FILTER="false"

if [ ! $FILTER = "true" ]; then
    while read FILE; do
        echo $FILE
    done
else
    while read FILE; do
        WAITING_LN=`cat $FILE | grep -n 'Waiting after end of match' | awk -F: '{print $1}'`
        PLAYER_DISCONNECTED_LN=`cat $FILE | grep -n 'A player disconnected' | awk -F: '{print $1}' | head -1`
        COACH_DISCONNECTED_LN=`cat $FILE | grep -n 'An online coach disconnected' | awk -F: '{print $1}' | head -1`

        if [ $PLAYER_DISCONNECTED_LN -gt $WAITING_LN ] && [ $COACH_DISCONNECTED_LN -gt $WAITING_LN ]; then
            echo $FILE
        fi
    done
fi
