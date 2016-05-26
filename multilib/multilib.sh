#!/bin/bash
# WARNING: This script is only an example, the result of running this depends 
# on host machine and the environment variable you have set.
#
CT_TOP_DIR=${TOP_DIR}
. ${TOP_DIR}/.config

ML_DIR=${TOP_DIR}/multilib/multilib_scripts
. ${ML_DIR}/gcc_shared_multilib.sh
. ${ML_DIR}/startfile_multilib.sh
. ${ML_DIR}/libc_multilib.sh

if [ -z $1 ]; then return 0; fi

case $1 in
    libc_start_files)
       startfile_multilib; 
	;;
    gcc_core_pass_2) 
	gcc_shared_multilib; 
	;;
    libc)
	libc_multilib;
	;;
    *)
	;;
esac
