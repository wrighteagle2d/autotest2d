#!/bin/bash

RESULT_DIR="result.d"
PARSE="../parse.awk"
PROCESS="../process.awk"

if [ ! -z $1 ]; then
    RESULT_DIR=$1
fi

cd $RESULT_DIR 2>/dev/null || exit

RESULT_LIST=`ls -1 | grep '[0-9]\+' | sort -n`

parseall() {
    for i in $RESULT_LIST; do
        cat $i | awk -f $PARSE
    done 
}

cat `echo $RESULT_LIST | awk '{print $1}'` | grep '\<vs\>' | sed -e 's/\t//g'
echo
parseall | ../process.py
