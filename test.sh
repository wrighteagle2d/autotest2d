#!/bin/bash

MATCHES=3
ROUNDS=100

server() {
	ulimit -t 180
	rcssserver $*
}

match() {
	SERVER_HOST=$1

	RESULT="result_$SERVER_HOST"
	LOGDIR="log_$SERVER_HOST"

	OPTIONS=""
	OPTIONS="$OPTIONS -server::team_l_start=\"./start_left $SERVER_HOST\""
	OPTIONS="$OPTIONS -server::team_r_start=\"./start_right $SERVER_HOST\""
	OPTIONS="$OPTIONS -server::game_log_dir=\"./$LOGDIR/\""
	OPTIONS="$OPTIONS -server::text_log_dir=\"./$LOGDIR/\""
	OPTIONS="$OPTIONS -server::nr_normal_halfs=2 -server::nr_extra_halfs=0"
	OPTIONS="$OPTIONS -server::penalty_shoot_outs=false -server::auto_mode=on"
	OPTIONS="$OPTIONS -server::game_logging=true -server::text_logging=false"
	OPTIONS="$OPTIONS -server::host=\"$SERVER_HOST\""

	mkdir $LOGDIR
	exec > $RESULT

	for i in `seq 1 $ROUNDS`; do
		server $OPTIONS
		sleep 5
	done
}

autotest() {
	./clear.sh

	export LANG=POSIX
	SERVER_HOSTS=(`ifconfig | grep -o 'inet addr:192\.168\.26\.[0-9]\+' | grep -o '192\.168\.26\.[0-9]\+'`)

	TOTAL_ROUNDS=`expr $MATCHES '*' $ROUNDS`
	echo $TOTAL_ROUNDS > total_rounds

	i=0
	while [ $i -lt $MATCHES ] && [ $i -lt ${#SERVER_HOSTS[@]} ]; do
		match ${SERVER_HOSTS[$i]} &
		i=`expr $i + 1`
		sleep 30
	done
}

if [ $# -gt 0 ]; then
	autotest
else
	$0 $# &
fi

