#!/bin/bash

RESULT="result"
RESULT_DIR="result.d"
AWKFILE="../statistic.awk"

cd $RESULT_DIR 2>/dev/null || exit
cat `ls -1 -r --sort=t result_*` >$RESULT

grep '\<vs\>' $RESULT  | uniq | sed -e 's/\t//g'
echo
grep 'Score' $RESULT | awk -f $AWKFILE
