#!/bin/bash

RESULT_DIR="result.d"
DATA="$RESULT_DIR/plot"
GNUPLOT="./plot.gp"

echo "#count win_rate expected_win_rate" > $DATA
./result.sh --analyze >> $DATA

$GNUPLOT

EOG=`which eog`

if [ ! -z $EOG ]; then
    $EOG "$RESULT_DIR/result.png"
fi

