#!/bin/bash

PROJECT_NAME=demo

WORK_DIR=`dirname $0`
WORK_DIR=`cd ${WORK_DIR}; pwd`
echo "Work dir: ${WORK_DIR}"

echo "Setting up environment variables ..."

MAVEN_HOME=${M2_HOME}
if [ ! -d "${MAVEN_HOME}" ]; then
    MAVEN_HOME=${WORK_DIR}/../thirdparty/maven/apache-maven-3.1.1
fi

JAVA_HOME=${JAVA_HOME}
if [ ! -d "${JAVA_HOME}" ]; then
    JAVA_HOME=$BUILD_KIT_PATH/java/jdk-1.7u60
fi

export MAVEN_HOME && export JAVA_HOME
export PATH=${MAVEN_HOME}/bin:${JAVA_HOME}/bin:${PATH}

echo "Running maven ..."
if [ $# -eq 0 ]; then
    mvn -DskipTests -Dspring.profiles.active=test clean package
elif [ $1 == "all" ]; then
    mvn -DskipTests clean package
else
    mvn $@
    exit
fi

if [ $? -ne 0 ]; then
    echo "error: mvn build failed!!!"
    exit 1
fi

echo "Start to building packages."

echo "Prepare package structure"
OUTPUT_DIR=${WORK_DIR}/output

if [ -d ${OUTPUT_DIR} ]; then
    echo "Remove output dir ..."
    rm -rf ${OUTPUT_DIR}
fi

echo "Make output dir ..."
mkdir -p ${OUTPUT_DIR}

echo "Switch to output dir"
cd ${OUTPUT_DIR}

echo "Downloading java8..."
if [ ! -d java8 ]; then
    wget -q ftp://product.scm.baidu.com/data/prod-64/scm/java-build/java-build_1-0-3-1_PD_BL/output/jdk-1.8-8u20.20141210.tar.bz2 --user getprod --password getprod
    tar -jxf jdk-1.8-8u20.20141210.tar.bz2
    echo "Preparing java8..."
    mv jdk-1.8-8u20 java8
    echo "remove file jdk-1.8-8u20.20141210.tar.bz2"
    rm -f jdk-1.8-8u20.20141210.tar.bz2
fi

echo "Copy ${PROJECT_NAME}.jar to output dir..."
cp ${WORK_DIR}/target/${PROJECT_NAME}.jar ${OUTPUT_DIR}

VERSION_NAME=server.version
VERSION_FILE=${WORK_DIR}/src/main/resources/${VERSION_NAME}
echo "Generate version and timestamp..."

rm -f ${VERSION_FILE}

if [ X$FOURBIT_VERSION != X"" ]; then
  echo "Version: ${FOURBIT_VERSION}" >> ${VERSION_FILE}
fi
echo "BuildTime: "$(date "+%Y-%m-%d %H:%M:%S") >> ${VERSION_FILE}
# svn info >> ${VERSION_FILE}

for pkg in `ls ${WORK_DIR}/deploy |grep resources | awk -F"resources_" '{print $2}'`
do
    PACKAGE_NAME=${PROJECT_NAME}_${pkg}.tar.gz
    echo "Start building package ${PACKAGE_NAME}."

    for folder in ls `ls ${WORK_DIR}/build/`
    do
        rm -rf ${OUTPUT_DIR}/${folder}
    done

    cp -rf ${WORK_DIR}/build/* ${OUTPUT_DIR}
    find ${OUTPUT_DIR}/bin -name '*.sh' | xargs chmod 755
    find ${OUTPUT_DIR}/bin -name '*.sh' | xargs dos2unix

    echo "Copy version info"
    cp ${VERSION_FILE} ${OUTPUT_DIR}/conf/

    echo "Copy noah deploy"
    cp -rf ${WORK_DIR}/deploy/noah-deploy_${pkg}/* ${OUTPUT_DIR}/noahdes/
    echo "Copy configuration files"
    cp -rf ${WORK_DIR}/deploy/resources_${pkg}/* ${OUTPUT_DIR}/conf/

    echo "Delete .svn file ..."
    for svnFile in `find . -name ".svn"`;do
        rm -rf ${svnFile};
    done

    echo `pwd`
    tar -czf ${PACKAGE_NAME} `ls ${OUTPUT_DIR}`
    if [ $? -ne 0 ]; then
        echo "create "${PACKAGE_NAME} "failed!"
        exit 2
    fi
done

ls ${OUTPUT_DIR} | grep -v ".tar.gz" | xargs rm -rf
echo `ls`" build success at dir "${OUTPUT_DIR}
exit 0
