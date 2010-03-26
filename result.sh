#!/bin/bash

RESULT="result"
RESULT_DIR="result.d"
AWKFILE="../statistic.awk"

cd $RESULT_DIR || exit
cat `ls -1 -r --sort=t 192.168.*` >$RESULT

grep '\<vs\>' $RESULT  | uniq | sed -e 's/\t//g'
echo
grep 'Score' $RESULT | awk -f $AWKFILE
