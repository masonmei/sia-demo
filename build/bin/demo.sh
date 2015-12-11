#!/bin/bash

readonly PROJECT=demo
readonly MAIN_PORT=8888
readonly MAIN_CLASS=${PROJECT}.jar
readonly SERVER_PROPERTY="conf/application.yaml"

if [ $# != "1" ]; then
    usage
fi

DATE=`date +%Y%m%d-%H%M`
ACTION=$1

usage()
{
    echo  "Usage: "${PROJECT}".sh [start|stop|restart|check]"
}

init()
{
    echo "enter init"

    SCRIPT_DIR=`dirname $0`
    SCRIPT_DIR=`cd ${SCRIPT_DIR}; pwd`

    cd ..
    BASE_DIR=`pwd`
    echo "BASE_DIR dir:"${BASE_DIR}
}

checkUlimit()
{
    echo "enter checkULimit"
    RET=`ulimit -n`
#    echo "${RET}"
    if [ ${RET} -lt 10000 ];then
        echo "ulimit "${RET} "is less than 10000"
        RETVAL=1
    else
        RETVAL=0
    fi

    return ${RETVAL}
}

findProcess()
{
    RET=`ps aux | grep ${MAIN_CLASS} | grep ${BASE_DIR} | grep -v "grep"`
    return 0
}

checkProcess()
{
    echo "enter checkProcess"
    findProcess
    if [ -n "${RET}" ];then
        echo ${RET} |awk '{print $2}' >${PROJECT}.pid
        RETVAL=0
    else
        RETVAL=1
    fi

    return ${RETVAL}
}

checkPort()
{
    echo "enter checkPort"
    RET=`netstat -anp|grep ${MAIN_PORT}`
    if [ -n "${RET}" ];then
        RETVAL=0
    else
        RETVAL=1
    fi

    return ${RETVAL}
}

check()
{
    echo "enter check"
    echo ${DATE} ${PROJECT} ${ACTION} "begin!"
    checkProcess
    PROCESS=`echo $?`

    if [ ${PROCESS} -eq 0 ];then
        echo ${DATE} ${PROJECT} ${ACTION} "success!"
        RETVAL=0
    else
        echo ${DATE} ${PROJECT} ${ACTION} "fail!"
        RETVAL=1
    fi

    return ${RETVAL}
}

start()
{
    echo "enter start"
    echo ${DATE} ${PROJECT} ${ACTION} "begin!"

    checkProcess
    PROCESS=`echo $?`
    if [ ${PROCESS} -eq 0 ];then
        echo ${PROJECT} "is already started!"
        RETVAL=1
        return ${RETVAL}
    fi

    checkUlimit
    ULIMIT=`echo $?`
    if [ ${ULIMIT} -eq 1 ];then
        echo "ulimit is not enough!"
        RETVAL=1
        return ${RETVAL}
    fi

    LOGS_DIR=${WORK_DIR}/log
    CONF_DIR=${WORK_DIR}/conf

    if [ ! -d ${LOGS_DIR} ];then
        mkdir -p ${LOGS_DIR}
    fi

    echo "Setting up environment variable..."
    JAVA_HOME=${WORK_DIR}/java8

    CLASSPATH=.:${JAVA_HOME}/lib/dt.jar:${JAVA_HOME}/lib.tools.jar
    CLASSPATH=${CLASSPATH}:${CONF_DIR}

    export CLASSPATH

    JAVA_ARGS="-server -Xmx8096m -Xms8096m -Xmn2048m -XX:SurvivorRatio=8 -XX:PermSize=512m -XX:MaxPermSize=512m -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:+CMSClassUnloadingEnabled -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=80 -XX:+UseCMSCompactAtFullCollection -XX:CMSFullGCsBeforeCompaction=0 -XX:-CMSParallelRemarkEnabled -XX:SoftRefLRUPolicyMSPerMB=0 -XX:MaxTenuringThreshold=7 -Xloggc:${LOGS_DIR}/${PROJECT}-gc.log -XX:+PrintGCDateStamps -XX:+PrintGCDetails -XX:+PrintHeapAtGC -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=20M -Djava.io.tmpdir=tmp"

    if [ -f ${LOGS_DIR}/gc.log ];then
        mv ${LOGS_DIR}/gc.log ${LOGS_DIR}/gc.log.${DATE}
    fi

    nohup ${JAVA_HOME}/bin/java ${JAVA_ARGS} -jar ${MAIN_CLASS} --spring.config.location=${SERVER_PROPERTY} 1>/dev/null 2>&1 &
    sleep 3

    checkProcess
    PROCESS=`echo $?`
    if [ ${PROCESS} -eq 0 ];then
         echo ${DATE} ${PROJECT} ${ACTION} "success!"
         RETVAL=0
    else
         echo ${DATE} ${PROJECT} ${ACTION} "fail!"
         RETVAL=2
    fi

    return ${RETVAL}
}

stop()
{
    echo "enter stop"
    echo ${DATE} ${PROJECT} ${ACTION} "begin!"

    checkProcess
    PROCESS=`echo $?`
    if [ ${PROCESS} -eq 1 ];then
        echo ${PROJECT} "is already stopped!"
        RETVAL=1
        return ${RETVAL}
    fi

    SERVER_PIDS=`echo ${RET} | awk '{print $2}'`
    for id in $SERVER_PIDS;do
       kill -9 ${id}
       echo "kill process,pid:${id}"
    done

    checkProcess
    PROCESS=`echo $?`
    if [ ${PROCESS} -eq 0 ];then
          echo ${DATE} ${PROJECT} ${ACTION} "fail!"
          RETVAL=2
     else
          echo ${DATE} ${PROJECT} ${ACTION} "success!"
          RETVAL=0
     fi

     return ${RETVAL}
}

init
RETVAL=1
case "${ACTION}" in
    *restart)
    stop
    sleep 1
    start
    ;;

    *start)
    start
    ;;

    *stop)
    stop
    ;;

    *check)
    check
    ;;

    *reload)
    reload
    ;;

    *)
    usage
    ;;
esac

exit ${RETVAL}
