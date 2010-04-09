#!/bin/bash

RESULT_DIR="result.d"
PARSE="../parse.awk"
PROCESS="../process.py"
MARK="/tmp/result_running"

if [ ! -z $1 ]; then
    RESULT_DIR=$1
fi

cd $RESULT_DIR 2>/dev/null || exit

RESULT=`mktemp`
RESULT_LIST=`ls -1 | grep '[0-9]\+' | sort -n`

parseall() {
    for i in $RESULT_LIST; do
        cat $i | awk -f $PARSE
    done
}

spinner() {
    local DELAY=0.05
    while [ -f $MARK ]; do
        echo -n '/' ; sleep $DELAY
        echo -n '-' ; sleep $DELAY
        echo -n '\' ; sleep $DELAY
        echo -n '|' ; sleep $DELAY
    done
}

rm -f $MARK
touch $MARK
spinner &
cat `echo $RESULT_LIST | awk '{print $1}'` | grep '\<vs\>' | sed -e 's/\t//g' >$RESULT
echo >$RESULT
parseall | python $PROCESS >$RESULT
rm -f $MARK
cat $RESULT
