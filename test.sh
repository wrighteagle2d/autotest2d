#!/bin/bash

PROCES=2               #同时比赛的server个数
ROUNDS=300             #每个测试过程的比赛场数
CLIENTS=("localhost")  #跑球队的机器ip列表，本地测试即为： CLIENTS=("localhost")，需要配置好无密码登录
DEFAULT_PORT=6000      #默认的server监听球员和monitor的端口号
CONTINUE="false"       #是否是继续上一次的测试（如果继续将不会删除上次测试的结果数据）
GAME_LOGGING="false"   #是否记录rcg
TEXT_LOGGING="false"   #是否记录rcl
TEMP="true"	           #Can be killed any time?

###############

RESULT_DIR="result.d"
TOTAL_ROUNDS_FILE="$RESULT_DIR/total_rounds"
TIME_STAMP_FILE="$RESULT_DIR/time_stamp"
HTML="/tmp/result.html"
HTML_GENERATING_LOCK="/tmp/autotest_html_generating"

run_server() {
	ulimit -t 300
    rcssserver $*
}

server_count() {
    ps -o pid= -C rcssserver | wc -l
}

match() {
    local HOST=$1
	local PORT=$2

	local OPTIONS=""
	local LOGDIR="log_$PORT"

    local COACH_PORT=`expr $PORT + 1`
    local OLCOACH_PORT=`expr $PORT + 2`

    local a=`expr $PORT / 1000`
    local b=`expr $a + 1`

    a=`expr $a % ${#CLIENTS[@]}`
    b=`expr $b % ${#CLIENTS[@]}`

    local LEFT_CLIENT=${CLIENTS[$a]}
    local RIGHT_CLIENT=${CLIENTS[$b]}

    OPTIONS="$OPTIONS -server::port=$PORT"
    OPTIONS="$OPTIONS -server::coach_port=$COACH_PORT"
    OPTIONS="$OPTIONS -server::olcoach_port=$OLCOACH_PORT"
	OPTIONS="$OPTIONS -server::game_log_dir=\"./$LOGDIR/\""
	OPTIONS="$OPTIONS -server::text_log_dir=\"./$LOGDIR/\""
	OPTIONS="$OPTIONS -server::nr_normal_halfs=2 -server::nr_extra_halfs=0"
	OPTIONS="$OPTIONS -server::penalty_shoot_outs=false -server::auto_mode=on"
	OPTIONS="$OPTIONS -server::game_logging=$GAME_LOGGING -server::text_logging=$TEXT_LOGGING"
    OPTIONS="$OPTIONS -server::team_l_start=\"./start_left $LEFT_CLIENT $HOST $PORT $COACH_PORT $OLCOACH_PORT\""
    OPTIONS="$OPTIONS -server::team_r_start=\"./start_right $RIGHT_CLIENT $HOST $PORT $COACH_PORT $OLCOACH_PORT\""

    if [ $GAME_LOGGING = "true" ] || [ $TEXT_LOGGING = "true" ]; then
        mkdir $LOGDIR
    fi

    rm -f $HTML_GENERATING_LOCK
    generate_html

	for i in `seq 1 $ROUNDS`; do
        local RESULT="$RESULT_DIR/`date +%s`"
		if [ ! -f $RESULT ]; then
            run_server $OPTIONS &> $RESULT
		fi
        generate_html
		sleep 15
	done
}

generate_html() {
    if [ ! -f $HTML_GENERATING_LOCK ]; then
        touch $HTML $HTML_GENERATING_LOCK
        chmod 777 $HTML $HTML_GENERATING_LOCK 2>/dev/null #allow others to delete or overwrite
        if [ $TEMP = "true" ]; then
            ./result.sh -HT >$HTML
        else
            ./result.sh --html >$HTML
    	fi

        echo -e "<hr>" >>$HTML
        echo -e "<p><small>"`whoami`" @ "`date`"</small></p>" >>$HTML
        rm -f $HTML_GENERATING_LOCK
    fi
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
        PRE_TOTAL_ROUNDS=`./result.sh --no-color | awk '{print $3}' | grep '[013]:[013]' | wc -l`
        TOTAL_ROUNDS=`expr $PROCES '*' $ROUNDS + $PRE_TOTAL_ROUNDS`
        echo $TOTAL_ROUNDS >$TOTAL_ROUNDS_FILE
        echo `date` >>$TIME_STAMP_FILE
    fi

    local IP_PATTERN='192\.168\.[0-9]\{1,3\}\.[0-9]\{1,3\}'
    local SERVER_HOSTS=(`ifconfig | grep -o "inet addr:$IP_PATTERN" | grep -o "$IP_PATTERN"`)
    local HOST="localhost"

    if [ ${#SERVER_HOSTS[@]} -gt 0 ]; then
        HOST=${SERVER_HOSTS[0]}
    fi

    local i=0
    while [ $i -lt $PROCES ]; do
        local PORT=`expr $DEFAULT_PORT + $i \* 1000`
        match $HOST $PORT &
        i=`expr $i + 1`
        sleep `expr 900 / $PROCES`
    done
}

if [ $# -gt 0 ]; then
	autotest
else
	$0 $# &
fi

