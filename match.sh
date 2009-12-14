#!/bin/bash

SERVER="./server.sh"
RANGE=`seq 1 100`

SERVER_HOST="localhost"

if [ ! -z $1 ]; then
	SERVER_HOST=$1
fi

RSTLOG="result_${SERVER_HOST}"

START_LEFT="-server::team_l_start=\"./start_left ${SERVER_HOST}\""
START_RIGHT="-server::team_r_start=\"./start_right ${SERVER_HOST}\""
GAME_LOG_DIR="-server::game_log_dir=\"./log/\""
TEXT_LOG_DIR="-server::text_log_dir=\"./log/\""
ADDITION_OPTS="-server::nr_normal_halfs=2 -server::nr_extra_halfs=0 -server::penalty_shoot_outs=false -server::auto_mode=on -server::game_logging=false -server::text_logging=false -server::host=\"${SERVER_HOST}\""

exec > $RSTLOG

for i in $RANGE; do
	$SERVER $START_LEFT $START_RIGHT $GAME_LOG_DIR $TEXT_LOG_DIR $ADDITION_OPTS
	sleep 5
done

