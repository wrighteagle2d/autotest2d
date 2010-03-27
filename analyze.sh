#!/bin/bash

RESULT="result"
RESULT_DIR="result.d"
AWKFILE="../analyze.awk"
GNUPLOT="../plot.gnuplot"

cd $RESULT_DIR 2>/dev/null || exit
cat `ls -1 -r --sort=t result_*` >$RESULT

exec > plot

echo "#count win_rate expected_win_rate"
grep 'Score' $RESULT | awk -f $AWKFILE

exec $GNUPLOT


