#!/bin/bash

RESULT="result"
STATAWK="statistic.awk"

cat result_* > $RESULT

grep '\<vs\>' $RESULT  | uniq | sed -e 's/\t//g'
echo
grep 'Score' $RESULT | awk -f $STATAWK
