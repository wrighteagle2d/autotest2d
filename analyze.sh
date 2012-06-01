#!/bin/bash

CURVE="true"
MAP="true"
EOG=`which eog`

RESULT_DIR="result.d"
CURVE_DATA="$RESULT_DIR/curve"
MAP_DATA="$RESULT_DIR/map"
GNUPLOT_CURVE="./scripts/curve.gp"
GNUPLOT_MAP="./scripts/map.gp"

[ -d $RESULT_DIR ] || exit


if [ $CURVE = "true" ]; then
    ./result.sh --curve > $CURVE_DATA
    $GNUPLOT_CURVE

    if [ ! -z $EOG ]; then
        $EOG "$RESULT_DIR/curve.png"
    fi
else
    echo "$0 -c to output winrate curve"
fi

if [ $MAP = "true" ]; then
    ./result.sh --map > $MAP_DATA
    $GNUPLOT_MAP

    if [ ! -z $EOG ]; then
        $EOG "$RESULT_DIR/map.png"
    fi
else
    echo "$0 -m to output score map"
fi


