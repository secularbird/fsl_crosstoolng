#!/bin/bash
# WARNING: This script is only an example, the result of running this depends 
# on host machine and the environment variable you have set.
#
#
startfile_multilib()
{
    local TC_PREFIX=arm-fsl-linux-gnueabi
    local build_dir=${CT_WORK_DIR}/${TC_PREFIX}/build/build-libc-start-files/
    local src_dir=${CT_WORK_DIR}/src/glibc-2.13
    local dest_dir_prefix=${CT_PREFIX_DIR}/${TC_PREFIX}/multi-libs/
    local CC_PATH=${CT_WORK_DIR}/${TC_PREFIX}/build/gcc-core-static/bin

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

    for ((index=0; index < ${#gcc_options[@]}; index++)) {
	# FIXME: add some code to check it this option is already built.
	if [ -e ${dest_dir_prefix}/${dest_dirname[index]}/usr/lib/crt1.o ]; then
		continue;
	fi
	cd ${build_dir}
	make distclean

	echo "libc_cv_forced_unwind=yes" > config.cache
	echo "libc_cv_c_cleanup=yes" >> config.cache

        BUILD_CC=i686-build_pc-linux-gnu-gcc CFLAGS="-mthumb-interwork -mlittle-endian -O2 -U_FORTIFY_SOURCE ${gcc_options[index]}" ASFLAGS="-mthumb-interwork -mlittle-endian -O2 -U_FORTIFY_SOURCE ${gcc_options[index]}" CC=${TC_PREFIX}-gcc AR=${TC_PREFIX}-ar RANLIB=${TC_PREFIX}-ranlib ${src_dir}/configure --prefix=/usr --build=i686-build_pc-linux-gnu --host=${TC_PREFIX} --cache-file=${build_dir}/config.cache --without-cvs --disable-profile --without-gd --with-headers=${dest_dir_prefix}/usr/include --disable-debug --disable-sanity-checks --enable-kernel=${CT_LIBC_GLIBC_MIN_KERNEL} --with-__thread --with-tls --enable-shared ${fp_config[index]} --enable-add-ons=cortex-strings,nptl,ports

#${CC_PATH}/${TC_PREFIX}-gcc CFLAGS="-O2 -U_FORTIFY_SOURCE ${gcc_options[index]}" CC="${TC_PREFIX}-gcc" AR=${TC_PREFIX}-ar RANLIB=${TC_PREFIX}-ranlib ${src_dir}/configure --prefix=/usr --build=i686-build_pc-linux-gnu --host=${TC_PREFIX} --without-cvs --disable-profile --disable-debug --without-gd --with-headers=${dest_dir_prefix}/usr/include --cache-file=config.cache --with-__thread --with-tls --enable-shared ${fp_config[index]} --enable-add-ons=nptl,ports --enable-kernel=${CT_LIBC_GLIBC_MIN_KERNEL}
        
        make OBJDUMP_FOR_HOST=${TC_PREFIX}-objdump CFLAGS="-mthumb-interwork -mlittle-endian -O2 -U_FORTIFY_SOURCE ${gcc_options[index]}" ASFLAGS="-mthumb-interwork -mlittle-endian -O2 -U_FORTIFY_SOURCE ${gcc_options[index]}" PARALLELMFLAGS= -j1 csu/subdir_lib
        
        mkdir ${dest_dir_prefix}/${dest_dirname[index]}/usr/lib -p
	cp -fpv csu/crt1.o csu/crti.o csu/crtn.o ${dest_dir_prefix}/${dest_dirname[index]}/usr/lib

        "${TC_PREFIX}-gcc" -nostdlib        \
                             -nostartfiles    \
                             -shared          \
                              -x c /dev/null   \
                              -o "${dest_dir_prefix}/${dest_dirname[index]}/usr/lib/libc.so"
    }

    cd ${dest_dir_prefix}
    mkdir default && mv lib usr default/
    ln -sfv default/usr usr
    ln -sfv default/lib lib
}
