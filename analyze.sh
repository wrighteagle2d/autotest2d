#!/bin/bash

RESULT="result"
RESULT_DIR="result.d"
AWKFILE="../analyze.awk"
GNUPLOT="../plot.gnuplot"

cd $RESULT_DIR 2>/dev/null || exit
cat `ls -1 | grep '[0-9]\+' | sort -n` >$RESULT

exec > plot

echo "#count win_rate expected_win_rate"
grep 'Score' $RESULT | awk -f $AWKFILE

exec $GNUPLOT


