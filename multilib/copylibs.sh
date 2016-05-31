#!/bin/bash

function copylibs()
{
    local -a dest_dirname

    dest_dirname[0]="armv7-a/arm/hard/a9"
    dest_dirname[1]="armv7-a/arm/hard/neon"
    dest_dirname[2]="armv7-a/arm/hard/vfpv3"
    dest_dirname[3]="armv7-a/arm/softfp/a9"
    dest_dirname[4]="armv7-a/arm/softfp/neon"
    dest_dirname[5]="armv7-a/arm/softfp/vfpv3"
    dest_dirname[6]="armv7-a/thumb/hard"
    dest_dirname[7]="armv7-a/thumb/softfp"
    dest_dirname[8]="armv7-a/thumb/a9"
    dest_dirname[9]="armv7-a/default"
    dest_dirname[10]="armv6/softfp"
    dest_dirname[11]="armv5"
    dest_dirname[12]="default"

    local DEST_ROOT=arm-fsl-linux-gnueabi/multi-libs/
    local SRC_ROOT=arm-fsl-linux-gnueabi/multi-libs/default/lib

    for ((index=0; index < ${#dest_dirname[@]}; index++)) {
        mv ${SRC_ROOT}/${dest_dirname[index]}/*  ${DEST_ROOT}/${dest_dirname[index]}/usr/lib
    }

    rm -rf ${SRC_ROOT}/armv7-a
    rm -rf ${SRC_ROOT}/armv6
    rm -rf ${SRC_ROOT}/armv5
    rm -rf ${SRC_ROOT}/default

}

copylibs
