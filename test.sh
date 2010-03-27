#!/bin/bash

PROCES=3
ROUNDS=100
GAME_LOGGING="false"
TEXT_LOGGING="false"

###############

RESULT_DIR="result.d"

server() {
	ulimit -t 180
	rcssserver $*
}

killall_server() {
    killall -9 rcssserver
    killall -9 rcssserver.bin
}

test_host_option() {
	SUPPORT_HOST_OPTION="false"

    OPTIONS="-server::host=\"127.0.0.1\""
	OPTIONS="$OPTIONS -server::game_logging=false -server::text_logging=false"

    killall_server 1>/dev/null 2>&1
    server $OPTIONS 1>/dev/null 2>&1 &
    sleep 1
    if [ `ps -o pid= -C rcssserver | wc -l` -gt 0 ]; then
       SUPPORT_HOST_OPTION="true"
    fi
    killall_server 1>/dev/null 2>&1

	echo $SUPPORT_HOST_OPTION
}

match() {
    SERVER_HOST=$1
	USE_HOST=$2

	LOGDIR="log_$SERVER_HOST"

	OPTIONS=""
	OPTIONS="$OPTIONS -server::game_log_dir=\"./$LOGDIR/\""
	OPTIONS="$OPTIONS -server::text_log_dir=\"./$LOGDIR/\""
	OPTIONS="$OPTIONS -server::team_l_start=\"./start_left $SERVER_HOST\""
	OPTIONS="$OPTIONS -server::team_r_start=\"./start_right $SERVER_HOST\""
	OPTIONS="$OPTIONS -server::nr_normal_halfs=2 -server::nr_extra_halfs=0"
	OPTIONS="$OPTIONS -server::penalty_shoot_outs=false -server::auto_mode=on"
	OPTIONS="$OPTIONS -server::game_logging=$GAME_LOGGING -server::text_logging=$TEXT_LOGGING"

    if [ $USE_HOST = "true" ]; then
        OPTIONS="$OPTIONS -server::host=\"$SERVER_HOST\""
    fi

    if [ $GAME_LOGGING = "true" ] || [ $TEXT_LOGGING = "true" ]; then
        mkdir $LOGDIR
    fi

	for i in `seq 1 $ROUNDS`; do
        RESULT="$RESULT_DIR/result_${SERVER_HOST}_$i"
        server $OPTIONS 1>$RESULT 2>&1
		sleep 5
	done
}

autotest() {
    export LANG=POSIX
	./clear.sh

    mkdir $RESULT_DIR
	TOTAL_ROUNDS=`expr $PROCES '*' $ROUNDS`
	echo $TOTAL_ROUNDS > $RESULT_DIR/total_rounds

	if [ `test_host_option` = "true" ]; then
		IP_PATTERN='192\.168\.[0-9]\{1,3\}\.[0-9]\{1,3\}'
		SERVER_HOSTS=(`ifconfig | grep -o "inet addr:$IP_PATTERN" | grep -o "$IP_PATTERN"`)

		if [ ${#SERVER_HOSTS[@]} -gt 0 ]; then
			i=0
			while [ $i -lt $PROCES ] && [ $i -lt ${#SERVER_HOSTS[@]} ]; do
				match ${SERVER_HOSTS[$i]} true &
				i=`expr $i + 1`
				sleep 30
			done
		else
			match localhost true &
		fi
	else
		match localhost false &
	fi
}

if [ $# -gt 0 ]; then
	autotest
else
	$0 $# &
fi

