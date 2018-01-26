#!/bin/bash
# RUN THIS SECOND
#
# Assumes you already ran 'llvm_setup_wget.sh'
#

# XXX: EDIT HERE
LLVM_VERSION=5.0.1
#LLVM_BASEDIR=/home/tjn/projects/ompi-ecp/source/llvm/$LLVM_VERSION
LLVM_BASEDIR=/home/tjn/projects/ompi-ecp/source/llvm-vanilla/$LLVM_VERSION

#--------------------------------------------------------------

# Quick Sanity checks
if [ ! -d $LLVM_BASEDIR/source/llvm ] ; then
    echo "ERROR: Missing source directory (tree setup properly?)"
    echo "       $LLVM_BASEDIR/source/llvm"
    exit 1
fi

if [ ! -d $LLVM_BASEDIR/build ] ; then 
    echo "ERROR: Missing build directory (tree setup properly?)"
    echo "       $LLVM_BASEDIR/build"
    exit 1
fi

if [ ! -d $LLVM_BASEDIR/install ] ; then 
    echo "ERROR: Missing install directory (tree setup properly?)"
    echo "       $LLVM_BASEDIR/install"
    exit 1
fi

#-----------------------------------------
#
# 4. Configure/Build
#   - NOTE: Build types: 'Release', 'Debug' (default), 'RelWithDebInfo'.
#   - NOTE: Assertions are off except in 'Debug'.
#
#-----------------------------------------

 #
 # RELEASE BUILD (PRODUCTION)
 #
cd $LLVM_BASEDIR/
cd build/release/
echo "CWD: `pwd`"
cmake -G "Unix Makefiles" \
    -DCMAKE_INSTALL_PREFIX=$LLVM_BASEDIR/install/release \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_ENABLE_ASSERTIONS=Off  \
    ../../source/llvm/ \
&& make -j 4 \
&& make install \
&& echo "SUCCESS: Install=$LLVM_BASEDIR/install/release"


 #
 # DEBUG BUILD (DEVELOPMENT)
 #
cd $LLVM_BASEDIR/
cd build/debug/
echo "CWD: `pwd`"
cmake -G "Unix Makefiles" \
    -DCMAKE_INSTALL_PREFIX=$LLVM_BASEDIR/install/debug \
    -DCMAKE_BUILD_TYPE=Debug \
    -DLLVM_ENABLE_ASSERTIONS=On  \
    ../../source/llvm/ \
&& make -j 4 \
&& make check-all \
&& make install \
&& echo "SUCCESS: Install=$LLVM_BASEDIR/install/debug"

# make check-all  (run regression tests)
