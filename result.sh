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

spinner &
SPINNER_PID=$!

RESULT=`mktemp`
RESULT_LIST=`ls -1 | grep '[0-9]\+' | sort -n`
#cat `echo $RESULT_LIST | awk '{print $1}'` | grep '\<vs\>' | sed -e 's/\t//g' >>$RESULT
echo >>$RESULT

parseall() {
    local TITLE="N/A"
    for i in $RESULT_LIST; do
        if [ "$TITLE" = "N/A" ]; then
            TITLE=`cat $i | grep '\<vs\>' | sed -e 's/\t//g'`
            echo $TITLE
        fi
        cat $i | awk -f $PARSE
    done
}

parseall | python $PROCESS $* >>$RESULT

exec 2>/dev/null
kill $SPINNER_PID

cat $RESULT
rm -f $RESULT

