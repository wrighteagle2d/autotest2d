#!/bin/bash

RESULT="result"
RESULT_DIR="result.d"
AWKFILE="../analyze.awk"
GNUPLOT="../plot.gnuplot"

cd $RESULT_DIR || exit
cat `ls -1 -r --sort=t 192.168.*` >$RESULT

exec > plot

echo "#count win_rate expected_win_rate"
grep 'Score' $RESULT | awk -f $AWKFILE

exec $GNUPLOT


