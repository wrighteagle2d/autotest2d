#!/bin/bash

PROCES=1              #同时比赛的server个数
ROUNDS=100            #每个测试过程的比赛场数
CONTINUE="false"      #是否是继续上一次的测试（如果继续将不会删除上次测试的结果数据）
GAME_LOGGING="false"  #是否记录rcg
TEXT_LOGGING="false"  #是否记录rcl

###############

RESULT_DIR="result.d"
TOTAL_ROUNDS_FILE="$RESULT_DIR/total_rounds"
TIME_STAMP_FILE="$RESULT_DIR/time_stamp"
HTML="/tmp/result.html"

run_server() {
	ulimit -t 180
	rcssserver $*
}

server_count() {
    ps -o pid= -C rcssserver | wc -l
}

killall_server() {
    killall -9 rcssserver
    killall -9 rcssserver.bin
}

support_host_option() {
	local SUPPORT_HOST_OPTION="false"
    local OPTIONS="-server::host=\"127.0.0.1\""

	OPTIONS="$OPTIONS -server::game_logging=false -server::text_logging=false"

    killall_server 1>/dev/null 2>&1
    run_server $OPTIONS 1>/dev/null 2>&1 &
    sleep 1
    if [ `server_count` -gt 0 ]; then
       SUPPORT_HOST_OPTION="true"
    fi
    killall_server 1>/dev/null 2>&1

	echo $SUPPORT_HOST_OPTION
}

match() {
    local SERVER_HOST=$1
	local USE_HOST=$2
	local OPTIONS=""
	local LOGDIR="log_$SERVER_HOST"

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
        RESULT="$RESULT_DIR/`date +%s`"
		if [ ! -f $RESULT ]; then
			run_server $OPTIONS 1>$RESULT 2>&1
		fi
		sleep 5
	done
}

generate_html() {
    local BREAK="false"

    sleep 10
    while [ 1 ]; do
        touch $HTML
        chmod 777 $HTML
        ./result.sh --verbose --html >$HTML
        echo -e "<hr>" >>$HTML
        echo -e "<p><small>"`whoami`" @ "`date`"</small></p>" >>$HTML

        if [ $BREAK = "true" ]; then
            break
        fi

        if [ `server_count` -eq 0 ]; then
            sleep 20
            if [ `server_count`-eq 0 ]; then
                BREAK="true"
                continue
            fi
        fi

        sleep 900
    done
}

autotest() {
    export LANG="POSIX"

    if [ `server_count` -gt 0 ]; then
        echo "Error: other server running, exit"
        exit
    fi

    if [ $CONTINUE = "false" ]; then
        if [ -d $RESULT_DIR ]; then
			echo "Warning: previous test result left, backuped"
			mv $RESULT_DIR ${RESULT_DIR}_`date +"%F_%H%M"`
        fi
        mkdir $RESULT_DIR || exit
        TOTAL_ROUNDS=`expr $PROCES '*' $ROUNDS`
        echo $TOTAL_ROUNDS >$TOTAL_ROUNDS_FILE
        echo `date` >$TIME_STAMP_FILE
    else
        if [ ! -d $RESULT_DIR ]; then
			echo "Error: can not find previous test result"
            exit
        fi
        PRE_TOTAL_ROUNDS=`./result.sh --verbose --no-color | awk '{print $3}' | grep '[013]:[013]' | wc -l`
        TOTAL_ROUNDS=`expr $PROCES '*' $ROUNDS + $PRE_TOTAL_ROUNDS`
        echo $TOTAL_ROUNDS >$TOTAL_ROUNDS_FILE
        echo `date` >>$TIME_STAMP_FILE
    fi

	if [ `support_host_option` = "true" ]; then
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

    generate_html
}

if [ $# -gt 0 ]; then
	autotest
else
	$0 $# &
fi

