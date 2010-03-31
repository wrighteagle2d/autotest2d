#!/bin/bash

RESULT_DIR="result.d"
AWKFILE="../statistic.awk"

if [ ! -z $1 ]; then
    RESULT_DIR=$1
fi

cd $RESULT_DIR 2>/dev/null || exit
RESULT_LIST=`ls -1 | grep '[0-9]\+' | sort -n`
cat `echo $RESULT_LIST | awk '{print $1}'` | grep '\<vs\>' | sed -e 's/\t//g'
echo
cat $RESULT_LIST | grep 'Score' | awk -f $AWKFILE
