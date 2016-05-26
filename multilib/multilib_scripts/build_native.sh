#!/bin/bash
BUILD_NATIVE_DIR=${CT_WORK_DIR}/${TC_PREFIX}/native
if [ ! -e ${BUILD_NATIVE_DIR} ]; then
	mkdir ${BUILD_NATIVE_DIR}
fi

cd ${BUILD_NATIVE_DIR} || exit 1

mkdir ${BUILD_NATIVE_DIR}/build-gmp
cd ${BUILD_NATIVE_DIR}/build-gmp || exit 1
CFLAGS=' -pipe -fexceptions' ${CT_WORK_DIR}/src/gmp-5.0.1/configure --build=i686-build_pc-linux-gnu --host=arm-fsl-linux-gnueabi --prefix=${BUILD_NATIVE_DIR} --enable-fft --enable-mpbsd --enable-cxx --disable-shared --enable-static
make; make install || exit 1

mkdir ${BUILD_NATIVE_DIR}/build-mpfr; cd ${BUILD_NATIVE_DIR}/build-mpfr || exit 1
CFLAGS=' -pipe' ${CT_WORK_DIR}/src/mpfr-3.0.1/configure --build=i686-build_pc-linux-gnu --host=arm-fsl-linux-gnueabi --prefix=${BUILD_NATIVE_DIR} --with-gmp=${BUILD_NATIVE_DIR} --disable-shared --enable-static
make; make install || exit 1

mkdir ${BUILD_NATIVE_DIR}/build-ppl; cd ${BUILD_NATIVE_DIR}/build-ppl || exit 1
CFLAGS=' -pipe' CXXFLAGS=' -pipe' ${CT_WORK_DIR}/src/ppl-0.11.2/configure --build=i686-build_pc-linux-gnu --host=arm-fsl-linux-gnueabi --prefix=${BUILD_NATIVE_DIR} --with-libgmp-prefix=${BUILD_NATIVE_DIR} --with-libgmpxx-prefix=${BUILD_NATIVE_DIR} --with-gmp-prefix=${BUILD_NATIVE_DIR} --enable-watchdog --disable-debugging --disable-assertions --disable-ppl_lcdd --disable-ppl_lpsol --disable-shared --enable-interfaces=c c++ --enable-static
make; make install || exit 1

mkdir ${BUILD_NATIVE_DIR}/build-cloog-ppl; cd ${BUILD_NATIVE_DIR}/build-cloog-ppl || exit 1
CFLAGS=' -pipe' LDFLAGS='-lm' ${CT_WORK_DIR}/src/cloog-ppl-0.15.11/configure --build=i686-build_pc-linux-gnu --host=arm-fsl-linux-gnueabi --prefix=${BUILD_NATIVE_DIR} --with-gmp=${BUILD_NATIVE_DIR} --with-ppl=${BUILD_NATIVE_DIR} --with-bits=gmp --disable-shared --enable-static
make; make install || exit 1

mkdir ${BUILD_NATIVE_DIR}/build-mpc; cd ${BUILD_NATIVE_DIR}/build-mpc || exit 1
CFLAGS=' -pipe' ${CT_WORK_DIR}/src/mpc-0.9/configure --build=i686-build_pc-linux-gnu --host=arm-fsl-linux-gnueabi --prefix=${BUILD_NATIVE_DIR} --with-gmp=${BUILD_NATIVE_DIR} --with-mpfr=${BUILD_NATIVE_DIR} --disable-shared --enable-static
make; make install || exit 1

mkdir ${BUILD_NATIVE_DIR}/build-binutils; cd ${BUILD_NATIVE_DIR}/build-binutils || exit 1
CFLAGS='-pipe' ${CT_WORK_DIR}/src/binutils-2.21/configure --build=i686-build_pc-linux-gnu --host=arm-fsl-linux-gnueabi --target=arm-fsl-linux-gnueabi  --prefix=/usr --disable-nls --disable-werror --enable-ld=yes --enable-gold=no --enable-plugins --with-pkgversion='Freescale MAD -- Linaro 2011.07 -- Built at 2011/08/10 09:20' --disable-multilib
make configure-host
make LDFLAGS='-all-static'
make DESTDIR=${CT_PREFIX_DIR}/native/ install

LD_NATIVE_DIR}/build-cc; cd ${BUILD_NATIVE_DIR}/build-cc || exit 1
CC=arm-fsl-linux-gnueabi-gcc CC_FOR_TARGET=arm-fsl-linux-gnueabi-gcc AS_FOR_TARGET=arm-fsl-linux-gnueabi-as LD_FOR_TARGET=arm-fsl-linux-gnueabi-ld CFLAGS="-pipe" CFLAGS_FOR_TARGET="-mthumb-interwork -mlittle-endian" LDFLAGS="-static -L${BUILD_NATIVE_DIR}/lib -lm -lstdc++ -lpwl" CXXFLAGS=" -mthumb-interwork -mlittle-endian"        LDFLAGS_FOR_TARGET=" -EL -static -lm -lstdc++ -lpwl" ${CT_WORK_DIR}/src/gcc-linaro-4.6-2011.06-0/configure --disable-bootstrap --build=i686-build_pc-linux-gnu --host=arm-fsl-linux-gnueabi --target=arm-fsl-linux-gnueabi --prefix=/usr --enable-languages=c,c++ --with-pkgversion="Freescale MAD -- Linaro 2011.07 -- Built at 2011/08/10 09:20" --enable-__cxa_atexit --disable-libmudflap --disable-libgomp --disable-libssp --with-gmp=${BUILD_NATIVE_DIR} --with-mpfr=${BUILD_NATIVE_DIR} --with-mpc=${BUILD_NATIVE_DIR} --with-ppl=${BUILD_NATIVE_DIR} --with-cloog=${BUILD_NATIVE_DIR} --with-libelf=${BUILD_NATIVE_DIR} --enable-threads=posix --enable-target-optspace --disable-libstdc__-v3 --disable-multilib --with-local-prefix=${CT_PREFIX_DIR}/native --disable-nls --enable-c99 --enable-long-long
make; make DESTDIR=${CT_PREFIX_DIR}/native/ install
