#!/bin/bash
set -e

mkdir -p build/$PLATFORM
cd build/$PLATFORM

ZLIB_VERSION=1.2.11
if [[ ! -e "zlib-$ZLIB_VERSION.tar.gz" ]]; then
    curl -L "http://zlib.net/zlib-$ZLIB_VERSION.tar.gz" -o "zlib-$ZLIB_VERSION.tar.gz"
fi
echo "c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1  zlib-$ZLIB_VERSION.tar.gz" | shasum -a 256 -c -

echo "Decompressing archives..."
tar --totals -xf "zlib-$ZLIB_VERSION.tar.gz"
cd zlib-$ZLIB_VERSION

case $PLATFORM in
    android-arm)
        $PLATFORM_ROOT/build/tools/make_standalone_toolchain.py --arch arm --api 21 --install-dir=../toolchain
        export PATH=`pwd`/../toolchain/bin/:$PATH
        CC="arm-linux-androideabi-clang -fPIC" ./configure --prefix=.. --static
        make -j $MAKEJ
        make install
        ;;
    android-arm64)
        $PLATFORM_ROOT/build/tools/make_standalone_toolchain.py --arch arm64 --api 21 --install-dir=../toolchain
        export PATH=`pwd`/../toolchain/bin/:$PATH
        CC="aarch64-linux-android-clang -fPIC" ./configure --prefix=.. --static
        make -j $MAKEJ
        make install
        ;;
    android-x86)
        $PLATFORM_ROOT/build/tools/make_standalone_toolchain.py --arch x86 --api 21 --install-dir=../toolchain
        export PATH=`pwd`/../toolchain/bin/:$PATH
        CC="i686-linux-android-clang -fPIC" ./configure --prefix=.. --static
        make -j $MAKEJ
        make install
        ;;
    android-x86_64)
        $PLATFORM_ROOT/build/tools/make_standalone_toolchain.py --arch x86_64 --api 21 --install-dir=../toolchain
        export PATH=`pwd`/../toolchain/bin/:$PATH
        CC="x86_64-linux-android-clang -fPIC" ./configure --prefix=.. --static
        make -j $MAKEJ
        make install
        ;;
    linux-x86)
        CC="gcc -m32 -fPIC" ./configure --prefix=.. --static
        make -j $MAKEJ
        make install
        ;;
    linux-x86_64)
        CC="gcc -m64 -fPIC" ./configure --prefix=.. --static
        make -j $MAKEJ
        make install
        ;;
    macosx-x86_64)
        ./configure --prefix=.. --static
        make -j $MAKEJ
        make install
        ;;
    windows-x86)
        nmake -f win32/Makefile.msc zlib.lib
        mkdir -p ../include ../lib
        cp zconf.h zlib.h ../include/
        cp zlib.lib ../lib/
        ;;
    windows-x86_64)
        nmake -f win32/Makefile.msc zlib.lib
        mkdir -p ../include ../lib
        cp zconf.h zlib.h ../include/
        cp zlib.lib ../lib/
        ;;
    *)
        echo "Error: Platform \"$PLATFORM\" is not supported"
        ;;
esac

cd ../../..
