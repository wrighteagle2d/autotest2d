#!/bin/bash

RESULT_DIR="result.d"
PARSE="../parse.awk"
PROCESS="../process.py"

cd $RESULT_DIR 2>/dev/null || exit

spinner() {
    local DELAY=0.05

    while [ 1 ]; do
        echo -n '/' ; sleep $DELAY
        echo -n '-' ; sleep $DELAY
        echo -n '\' ; sleep $DELAY
        echo -n '|' ; sleep $DELAY
    done
}

SPINNER_PID=-1
if [ $# -le 0 ]; then
    spinner &
    SPINNER_PID=$!
fi

RESULT=`mktemp`
RESULT_LIST=`ls -1 | grep '[0-9]\+' | sort -n`
#cat `echo $RESULT_LIST | awk '{print $1}'` | grep '\<vs\>' | sed -e 's/\t//g' >>$RESULT
echo >>$RESULT

parseall() {
    local TITLE="N/A"
    local CACHE_DIR="cache"

    mkdir $CACHE_DIR 2>/dev/null
    for i in $RESULT_LIST; do
        if [ "$TITLE" = "N/A" ]; then
            TITLE=`cat $i | grep '\<vs\>' | sed -e 's/\t//g'`
            if [ ! -f $CACHE_DIR/title ]; then
                echo $TITLE >$CACHE_DIR/title
            fi
            cat $CACHE_DIR/title
        fi
        if [ ! -f $CACHE_DIR/$i ]; then
            cat $i | awk -f $PARSE >$CACHE_DIR/$i
        fi
        cat $CACHE_DIR/$i
    done
}

parseall | python $PROCESS $* >>$RESULT

if [ $SPINNER_PID -gt 0 ]; then
    exec 2>/dev/null
    kill $SPINNER_PID
fi

cat $RESULT
rm -f $RESULT

