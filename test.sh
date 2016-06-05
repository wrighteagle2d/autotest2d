#!/bin/bash

PROCES=5              #number of simultaneously running servers

#CLIENTS=(
#    "192.168.26.102"
#    "192.168.26.103"
#    "192.168.26.104"
#    "192.168.26.110"
#    "192.168.26.120"
#    "192.168.26.102"
#    "192.168.26.103"
#    "192.168.26.110"
#    "192.168.26.120"
#    "192.168.26.102"
#    "192.168.26.103"
#)  #IPs of machines running clients，CLIENTS=("localhost") for testing on localhost，has to be configured as password-less login for SSH

CLIENTS=("localhost")

#CLIENTS=("192.168.26.102" "192.168.26.103")

ROUNDS=200             #number of games for each server
DEFAULT_PORT=6000      #default port connecting to server
CONTINUE="false"       #continue from last test
GAME_LOGGING="false"   #record RCG logs
TEXT_LOGGING="false"   #record RCL logs
MSG_LOGGING="false"    #record MSG logs for WrightEagle
TEMP="false"           #can be killed any time?
TRAINING="false"       #training mode
RANDOM_SEED="-1"       #random seed, -1 means random seeding
SYNCH_MODE="1"         #synch mode
FULLSTATE_L="0"        #full state mode for left
FULLSTATE_R="0"        #full state mode for right

############# do not need to change following parameters
RESTART_AS_TEMP="false"
IN_WRAPPER="false"
TEMP_MARKER="/tmp/autotest::temp"

while getopts  "r:p:ctkio" flag; do
    case "$flag" in
        r) ROUNDS=$OPTARG;;
        p) PROCES=$OPTARG;;
        c) CONTINUE="true";;
        t) TEMP="true";;
        o) TRAINING="true";;
        k) RESTART_AS_TEMP="true";;
        i) IN_WRAPPER="true";;
    esac
done

###############
if [ $RESTART_AS_TEMP = "true" ]; then
    if [ $IN_WRAPPER = "true" ]; then
        sleep 0.5
        ./test.sh -ct
        rm -f $0
        exit
    fi

    WRAPPER=`mktemp`
    cp $0 $WRAPPER
    chmod +x $WRAPPER
    $WRAPPER -ik &
    ./kill.sh
    exit
fi

echo "\$PROCES = $PROCES"
echo "\$ROUNDS = $ROUNDS"
echo "\$CONTINUE = $CONTINUE"
echo "\$TEMP = $TEMP"
echo "\$TRAINING = $TRAINING"
echo "\$RANDOM_SEED = $RANDOM_SEED"

rm -f $TEMP_MARKER
if [ $TEMP = "true" ]; then
    touch $TEMP_MARKER
    chmod 777 $TEMP_MARKER
fi

RESULT_DIR="result.d"
LOG_DIR="log.d"
TOTAL_ROUNDS_FILE="$RESULT_DIR/total_rounds"
TIME_STAMP_FILE="$RESULT_DIR/time_stamp"
HTML="$RESULT_DIR/index.html"
HTML_GENERATING_LOCK="/tmp/autotest_html_generating"

run_server() {
    ulimit -t 300
    echo rcssserver $*
    rcssserver $*
}

server_count() {
    ps -o pid= -C rcssserver | wc -l
}

match() {
    local HOST=$1
	local PORT=$2

	local OPTIONS=""

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
    OPTIONS="$OPTIONS -player::random_seed=$RANDOM_SEED"
	OPTIONS="$OPTIONS -server::nr_normal_halfs=2 -server::nr_extra_halfs=0"
	OPTIONS="$OPTIONS -server::penalty_shoot_outs=false -server::auto_mode=on"
	OPTIONS="$OPTIONS -server::game_logging=$GAME_LOGGING -server::text_logging=$TEXT_LOGGING"
	OPTIONS="$OPTIONS -server::game_log_compression=1 -server::text_log_compression=1"
	OPTIONS="$OPTIONS -server::game_log_fixed=1 -server::text_log_fixed=1"
	OPTIONS="$OPTIONS -server::synch_mode=$SYNCH_MODE"
	OPTIONS="$OPTIONS -server::fullstate_l=$FULLSTATE_L -server::fullstate_r=$FULLSTATE_R"
    OPTIONS="$OPTIONS -server::team_r_start=\"./start_right $RIGHT_CLIENT $HOST $PORT $COACH_PORT $OLCOACH_PORT\""

    if [ $TRAINING = "true" ]; then
        OPTIONS="$OPTIONS -server::coach=true -server::coach_w_referee=true"
    fi

    rm -f $HTML_GENERATING_LOCK
    generate_html

	for i in `seq 1 $ROUNDS`; do
        local TIME="`date +%Y%m%d%H%M`_$RANDOM"
        local RESULT="$RESULT_DIR/$TIME"

		if [ ! -f $RESULT ]; then
            local MSG_LOG_DIR="Logfiles_$TIME"
            local FULL_OPTIONS=""

            FULL_OPTIONS="$OPTIONS -server::game_log_dir=\"./$LOG_DIR/\" -server::text_log_dir=\"./$LOG_DIR/\""
            FULL_OPTIONS="$FULL_OPTIONS -server::game_log_fixed_name=\"$TIME\" -server::text_log_fixed_name=\"$TIME\""

            if [ $MSG_LOGGING = "true" ]; then
                FULL_OPTIONS="$FULL_OPTIONS -server::team_l_start=\"./start_left $LEFT_CLIENT $HOST $PORT $COACH_PORT $OLCOACH_PORT $TRAINING $MSG_LOG_DIR\""
            else
                FULL_OPTIONS="$FULL_OPTIONS -server::team_l_start=\"./start_left $LEFT_CLIENT $HOST $PORT $COACH_PORT $OLCOACH_PORT $TRAINING\""
            fi

            run_server $FULL_OPTIONS &>$RESULT
		fi

        sleep 1
        generate_html
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

        ./analyze.sh 2>/dev/null
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
			mv $LOG_DIR ${LOG_DIR}_`date +"%F_%H%M"`
        fi
        mkdir $RESULT_DIR || exit
        mkdir $LOG_DIR || exit
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
    local SERVER_HOSTS=(`/sbin/ifconfig | grep -o "inet addr:$IP_PATTERN" | grep -o "$IP_PATTERN"`)
    local HOST="localhost"

    if [ ${#SERVER_HOSTS[@]} -gt 0 ]; then
        HOST=${SERVER_HOSTS[0]}
    fi

    local i=0
    while [ $i -lt $PROCES ]; do
        local PORT=`expr $DEFAULT_PORT + $i \* 1000`
        match $HOST $PORT &
        i=`expr $i + 1`
        sleep 1
    done
}

autotest &

