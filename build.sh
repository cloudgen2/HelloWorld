#!/bin/sh

# @author Cloudgen Wong
# @date 2023-10-14

build_sub(){
    # create the target directory if it doesn't exist
    mkdir -p ${TARGET_DIR}
    rm -rf ${TARGET_FILE}

    # compile the program and output to the target directory
    gcc -Wall -Werror \
        src/main.c \
        src/parent-path.c \
        src/trim-quotes.c \
        -o ${TARGET_FILE} 2> $ERROR_LOG

    if [ $? -ne 0 ]; then
        echo "Build failed. Please check the error in $ERROR_LOG."
        exit 1
    fi

    # Make the binary executable
    chmod +x ${TARGET_FILE}
}

build_main() {

    if [ "$1" = "install" ]; then
        build_sub
        cp ${TARGET_FILE} /usr/bin/
        if [ $? -ne 0 ]; then
            echo "Cannot install to /usr/bin/${PRJ_NAME}"
        else
            echo "Build successful! Please run '${PRJ_NAME}'!"
        fi
    elif [ "$1" = clean ]; then
        rm -rf ${TARGET_DIR}/*
        echo "Folder ${TARGET_DIR} has been cleared!"
        rm -rf ${VC_X64_DIR}/*
        echo "Folder ${VC_X64_DIR} has been cleared!"
        rm -rf ${VC_SRC_X64_DIR}/*
        echo "Folder ${VC_SRC_X64_DIR} has been cleared!"
    elif [ "$1" = "test" ]; then
        build_sub
        # Set the necessary variables
        tests/test.sh ${TARGET_FILE} tests/cases/test-cases.txt
    else
        echo "Build successful! Please run '${TARGET_FILE}' or run './build test' for running test cases"
    fi
}

PRJ_NAME=$(cat src/src.vcxproj|grep "<ProjectName>"|cut -d\> -f2|cut -d\< -f1)
TARGET_DIR=target
TARGET_FILE=${TARGET_DIR}/${PRJ_NAM}
VC_X64_DIR=x64
VC_SRC_X64_DIR=src/x64
ERROR_LOG=${TARGET_DIR}/build-error.log
build_main "$1"