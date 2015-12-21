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
    echo "enter init function"

    SCRIPT_DIR=`dirname $0`
    SCRIPT_DIR=`cd ${SCRIPT_DIR}; pwd`
    cd ${SCRIPT_DIR}

    cd ..
    BASE_DIR=`pwd`
    echo "Application base directory is : ${BASE_DIR}"
    echo "Application starting script directory is : ${SCRIPT_DIR}"
    return 0
}

checkULimit()
{
    echo "enter checkULimit function"
    RET_ULIMIT=`ulimit -n`
    if [ ${RET_ULIMIT} -lt 10000 ];then
        echo "ULimit is ${RET_ULIMIT}, less than 10000"
        return 1
    else
        return 0
    fi
}

findProcess()
{
    echo "enter findProcess function"
    RET_PROCESS=`ps aux | grep ${MAIN_CLASS} | grep ${BASE_DIR} | grep -v "grep"`
    return 0
}

checkProcess()
{
    echo "enter checkProcess function"
    findProcess
    if [ -n "${RET_PROCESS}" ];then
        echo ${RET_PROCESS} |awk '{print $2}' >${PROJECT}.pid
        return 0
    else
        return 1
    fi
}

checkPort()
{
    echo "enter checkPort function"
    CHECK_PORT=`netstat -anp|grep ${MAIN_PORT}`
    if [ -n "${CHECK_PORT}" ];then
        return 0
    else
        return 1
    fi
}

check()
{
    echo "enter check function"
    echo ${DATE} ${PROJECT} ${ACTION} "begin!"
    checkProcess
    PROCESS=`echo $?`

    if [ ${PROCESS} -eq 0 ];then
        echo ${DATE} ${PROJECT} ${ACTION} "success!"
        return 0
    else
        echo ${DATE} ${PROJECT} ${ACTION} "fail!"
        return 1
    fi
}

start()
{
    echo "enter start"
    echo ${DATE} ${PROJECT} ${ACTION} "begin!"

    checkProcess
    if [ $? -eq 0 ];then
        echo "${PROJECT} is already started!"
        return 1
    fi

    checkPort
    if [ $? -eq 0 ]; then
        echo "Port ${MAIN_PORT} has already been used!"
        return 1
    fi

    checkULimit
    if [ $? -eq 1 ];then
        echo "ULimit is not enough!"
        return 1
    fi

    LOGS_DIR=${BASE_DIR}/log
    CONF_DIR=${BASE_DIR}/conf

    if [ ! -d ${LOGS_DIR} ];then
        mkdir -p ${LOGS_DIR}
    fi

    echo "Setting up environment variable..."
    JAVA_HOME=${BASE_DIR}/java8

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
    if [ $? -eq 0 ];then
         echo ${DATE} ${PROJECT} ${ACTION} "success!"
        return 0
    else
         echo ${DATE} ${PROJECT} ${ACTION} "fail!"
         return 2
    fi
}

stop()
{
    echo "enter stop"
    echo ${DATE} ${PROJECT} ${ACTION} "begin!"

    checkProcess
    if [ $? -eq 1 ];then
        echo "${PROJECT} is already stopped!"
        return 1
    fi

    SERVER_PIDS=`echo ${RET_PROCESS} | awk '{print $2}'`
    for id in ${SERVER_PIDS};do
       kill -9 ${id}
       echo "kill process,pid:${id}"
    done

    checkProcess
    if [ $? -eq 0 ];then
          echo ${DATE} ${PROJECT} ${ACTION} "fail!"
          return 2
     else
          echo ${DATE} ${PROJECT} ${ACTION} "success!"
          return 0
     fi
}

init
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
exit $?
