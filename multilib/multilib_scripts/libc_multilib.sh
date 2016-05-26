#!/bin/bash
# WARNING: This script is only an example, the result of running this depends 
# on host machine and the environment variable you have set.
#
#
libc_multilib()
{
    local TC_PREFIX=arm-fsl-linux-gnueabi
    local build_dir=${CT_WORK_DIR}/${TC_PREFIX}/build/build-libc/
    local src_dir=${CT_WORK_DIR}/src/glibc-2.13
    local dest_dir_prefix=${CT_PREFIX_DIR}/${TC_PREFIX}/multi-libs/
    local CC_PATH=${CT_WORK_DIR}/${TC_PREFIX}/build/gcc-core-shared/bin
   
     export PATH=${CT_PREFIX_DIR}/bin:${CC_PATH}:$PATH

    local -a gcc_options

    gcc_options[0]="-march=armv7-a -mfpu=neon -mfloat-abi=hard -mcpu=cortex-a9"
    gcc_options[1]="-march=armv7-a -mfpu=neon -mfloat-abi=hard"
    gcc_options[2]="-march=armv7-a -mfpu=vfpv3 -mfloat-abi=hard"
    gcc_options[3]="-march=armv7-a -mfpu=neon -mfloat-abi=softfp -mcpu=cortex-a9"
    gcc_options[4]="-march=armv7-a -mfpu=neon -mfloat-abi=softfp"
    gcc_options[5]="-march=armv7-a -mfpu=vfpv3 -mfloat-abi=softfp"
    gcc_options[6]="-march=armv7-a -mfpu=neon -mthumb -mfloat-abi=hard"
    gcc_options[7]="-march=armv7-a -mfpu=neon -mthumb -mfloat-abi=softfp"
    gcc_options[8]="-march=armv7-a -mfpu=neon -mthumb -mfloat-abi=softfp -mcpu=cortex-a9"
    gcc_options[9]="-march=armv7-a"
    gcc_options[10]="-march=armv6 -mfpu=vfp -mfloat-abi=softfp"
    gcc_options[11]="-march=armv5te"

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

    local -a fp_config

    fp_config[0]="--with-fp"
    fp_config[1]="--with-fp"
    fp_config[2]="--with-fp"
    fp_config[3]="--with-fp"
    fp_config[4]="--with-fp"
    fp_config[5]="--with-fp"
    fp_config[6]="--with-fp"
    fp_config[7]="--with-fp"
    fp_config[8]="--with-fp"
    fp_config[9]="--with-fp"
    fp_config[10]="--with-fp"
    fp_config[11]="--without-fp"

    for ((index=0; index < ${#dest_dirname[@]}; index++)) {
	# FIXME: add some code to check it this option is already built.
	if [ -e ${dest_dir_prefix}/${dest_dirname[index]}/lib/libc.so.6 ]; then
		continue;
	fi

	cd ${build_dir}
	make distclean
	rm  ${build_dir}/sunrpc/*

	echo "libc_cv_forced_unwind=yes" > config.cache
	echo "libc_cv_c_cleanup=yes" >> config.cache

        BUILD_CC=${CC_PATH}/${TC_PREFIX}-gcc CFLAGS="-O2 -U_FORTIFY_SOURCE ${gcc_options[index]}" CC="${TC_PREFIX}-gcc" AR=${TC_PREFIX}-ar RANLIB=${TC_PREFIX}-ranlib ${src_dir}/configure --prefix=/usr --includedir=/usr/include --build=i686-build_pc-linux-gnu --host=${TC_PREFIX} --without-cvs --disable-profile --disable-debug --without-gd --disable-sanity-checks --cache-file=config.cache --with-headers=${dest_dir_prefix}/usr/include --with-__thread --with-tls --enable-shared ${fp_config[index]} --enable-add-ons=nptl,ports --enable-kernel=${CT_LIBC_GLIBC_MIN_KERNEL}
        
        make OBJDUMP_FOR_HOST=${TC_PREFIX}-objdump CFLAGS="-O2 -U_FORTIFY_SOURCE ${gcc_options[index]}" ASFLAGS="${gcc_options[index]}" PARALLELMFLAGS= -j1 all
        
        make install_root=${dest_dir_prefix}/${dest_dirname[index]} OBJDUMP_FOR_HOST=${TC_PREFIX}-objdump PARALLELMFLAGS= -j1 install

	echo "${gcc_options[index]}" > ${dest_dir_prefix}/${dest_dirname[index]}/gcc_option
	# we only keep one header file copy.
	rm -rf ${dest_dir_prefix}/${dest_dirname[index]}/usr/include

    }
    cd ${dest_dir_prefix}
    mv etc sbin default/
    return 0
}
