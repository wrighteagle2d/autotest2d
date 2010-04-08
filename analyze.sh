#!/bin/bash

RESULT="result"
RESULT_DIR="result.d"
AWKFILE="../analyze.awk"
PLOTDATA="./plot"
GNUPLOT="../plot.gp"

if [ ! -z $1 ]; then
    RESULT_DIR=$1
fi


cd $RESULT_DIR 2>/dev/null || exit

echo "#count win_rate expected_win_rate" > $PLOTDATA
cat `ls -1 | grep '[0-9]\+' | sort -n` | grep 'Score' | awk -f $AWKFILE >> $PLOTDATA

$GNUPLOT

EOG=`which eog`

if [ ! -z $EOG ]; then
    $EOG result.png
fi

