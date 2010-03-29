#!/bin/bash

RESULT="result"
RESULT_DIR="result.d"
AWKFILE="../analyze.awk"
PLOTDATA="./plot"
GNUPLOT="../plot.gnuplot"

cd $RESULT_DIR 2>/dev/null || exit
echo "#count win_rate expected_win_rate" > $PLOTDATA
cat `ls -1 | grep '[0-9]\+' | sort -n` | grep 'Score' | awk -f $AWKFILE >> $PLOTDATA
exec $GNUPLOT


