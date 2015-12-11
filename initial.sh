#!/bin/bash

checkOs(){
    linux=false
    darwin=false
    case "`uname`" in
    Linux*) linux=true;;
    Darwin*) darwin=true;;
    esac
}

initIfNotExist(){
    if [ ! -f ${property_file} ];
    then
        echo "Initializing the configuration meta file"
        touch ${property_file}
        ls
        project_name=`ls ${WORK_DIR}/build/bin |grep control |awk -F"_control" '{print $1}'`
        project_port=`grep "readonly MAIN_PORT=" ${WORK_DIR}/build/bin/${project_name}.sh |awk -F"MAIN_PORT=" '{print $2}'`
        project_deploy_path=`grep "change_directory:" ${WORK_DIR}/build/conf/babysitter.conf | awk -F' ' '{print $2}' | awk -F '\"' '{print $2}'`

        echo "# this file is generated automatic, do not modify it." > ${property_file}
        echo "project_name=${project_name}" >> ${property_file}
        echo "project_port=${project_port}" >> ${property_file}
        echo "project_deploy_path=${project_deploy_path}" >> ${property_file}
    fi
}

changeName() {
    echo "This application name is ${new_project_name}"
    read -p "Enter new name:" name

    if [ "X"${name} != "X" ];
    then
        new_project_name=${name}
    fi
}

changePort() {
    echo "This application port is ${new_project_port}"
    read -p "Enter new port:" port

    if [ "X"${port} != "X" ];
    then
        new_project_port=${port}
    fi
}

changeDeployPath(){
    echo "This deploy path is ${new_project_deploy_path}"
    read -p "Enter new path:" deploy_path

    if [ "X"${deploy_path} != "X" ];
    then
        new_project_deploy_path=${deploy_path}
    fi
}


confirm(){
    echo "The configuration as following:"
    echo "Application Name: ${new_project_name}"
    echo "Application Port: ${new_project_port}"
    echo "Application Deploy Path: ${new_project_deploy_path}"

    read -p "Is this correct? (Y/n):" result

    if [ "X"${result} == "XY" ] || [ "X"${result} == "Xy" ] ;
    then
        echo "Applying changes."
        applyChange
        config_finished="yes"
    else
        echo "Please reEnter the application configuration."
    fi
}

applyChange(){
    echo "# this file is generated automatic, do not modify it." > ${property_file}
    echo "project_name=${new_project_name}" >> ${property_file}
    echo "project_port=${new_project_port}" >> ${property_file}
    echo "project_deploy_path=${new_project_deploy_path}" >> ${property_file}

    mv ${WORK_DIR}/build/bin/${project_name}.sh ${WORK_DIR}/build/bin/${new_project_name}.sh
    mv ${WORK_DIR}/build/bin/${project_name}_control ${WORK_DIR}/build/bin/${new_project_name}_control

    if ${darwin}; then
        sed -i '' -e "1,10s%^readonly PROJECT=${project_name}%readonly PROJECT=${new_project_name}%g" ${WORK_DIR}/build/bin/${new_project_name}.sh
        sed -i '' -e "1,10s%^readonly MAIN_PORT=${project_port}%readonly MAIN_PORT=${new_project_port}%g" ${WORK_DIR}/build/bin/${new_project_name}.sh

        sed -i '' -e "1,10s%^PROJECT_NAME=${project_name}%PROJECT_NAME=${new_project_name}%g" ${WORK_DIR}/build.sh

        sed -i '' -e "1s%${project_deploy_path}%${new_project_deploy_path}%g" ${WORK_DIR}/build/conf/babysitter.conf
        sed -i '' -e "2,\$s%${project_name}%${new_project_name}%g" ${WORK_DIR}/build/conf/babysitter.conf
    fi

    if ${linux}; then
        sed -i -e "1,10s%^readonly PROJECT=${project_name}%readonly PROJECT=${new_project_name}%g" ${WORK_DIR}/build/bin/${new_project_name}.sh
        sed -i -e "1,10s%^readonly MAIN_PORT=${project_port}%readonly MAIN_PORT=${new_project_port}%g" ${WORK_DIR}/build/bin/${new_project_name}.sh

        sed -i -e "1,10s%^PROJECT_NAME=${project_name}%PROJECT_NAME=${new_project_name}%g" ${WORK_DIR}/build.sh

        sed -i -e "1s%${project_deploy_path}%${new_project_deploy_path}%g" ${WORK_DIR}/build/conf/babysitter.conf
        sed -i -e "2,\$s%${project_name}%${new_project_name}%g" ${WORK_DIR}/build/conf/babysitter.conf
    fi

    echo "Application configuration applied."
}


WORK_DIR=`dirname $0`
WORK_DIR=`cd ${WORK_DIR}; pwd`
echo "Work dir: ${WORK_DIR}"

property_file=${WORK_DIR}/.app_meta

checkOs
initIfNotExist

source ${property_file}

new_project_name=${project_name}
new_project_port=${project_port}
new_project_deploy_path=${project_deploy_path}

config_finished="no"

while [ ""${config_finished} != "yes" ];
do
    changeName
    echo ""
    changePort
    echo ""
    changeDeployPath
    echo ""
    confirm
    echo ""
done
echo "Configure application success."