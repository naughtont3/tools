#!/bin/bash
# RUN THIS SECOND
#
# TJN: (14dec2017) ADJUSTED TO HAVE SEPARATE LLVM_INSTALL_DIR ON SUMMITDEV
#
# Assumes you already ran 'llvm_setup.sh'
#

# XXX: EDIT HERE
LLVM_VERSION="release_50"
LLVM_BASEDIR=/ccs/home/naughton/projects.summitdev/ompi-ecp/source/llvm/$LLVM_VERSION
#LLVM_INSTALL_DIR=/ccs/proj/stf010/naughton/summitdev/ompi-ecp/install/llvm/$LLVM_VERSION
LLVM_INSTALL_DIR=/ccs/home/naughton/projects.summitdev/ompi-ecp/install/llvm/$LLVM_VERSION

# XXX: EDIT HERE
MY_PMIX_INSTALL_DIR=/ccs/proj/stf010/naughton/summitdev/ompi-ecp/install

#--------------------------------------------------------------

time_begin=`date`

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

if [ ! -d $LLVM_INSTALL_DIR ] ; then
    echo "ERROR: Missing install directory (tree setup properly?)"
    echo "       $LLVM_INSTALL_DIR"
    exit 1
fi

if [ ! -d $MY_PMIX_INSTALL_DIR/include ] ; then
    echo "ERROR: Missing PMIX include directory (PMIX installed?)"
    echo "       $MY_PMIX_INSTALL_DIR/include"
    exit 1
fi

if [ ! -d $MY_PMIX_INSTALL_DIR/lib ] ; then
    echo "ERROR: Missing PMIX lib directory (PMIX installed?)"
    echo "       $MY_PMIX_INSTALL_DIR/lib"
    exit 1
fi

#-----------------------------------------
#
# 4. Configure/Build
#   - NOTE: Build types: 'Release', 'Debug' (default), 'RelWithDebInfo'.
#   - NOTE: Assertions are off except in 'Debug'.
#
#-----------------------------------------

######
# TJN: NOTE - Must manually add PMIX related CFLAGS and LDFLAGS when
# building tests, e.g., '-I<pmix_path>/include' '-L<pmix_path>/lib -lpmix'
######

###
# TJN: SKIPPING RELEASE BUILD FOR NOW
#
# 
#  #
#  # RELEASE BUILD (PRODUCTION)
#  # (Only 'make check-clang-openmp' to speed things up)
#  #
# cd $LLVM_BASEDIR/
# cd build/release/
# echo "CWD: `pwd`"
# rm -f  CMakeCache.txt
# rm -rf CMakeFiles
# CFLAGS=" -I$MY_PMIX_INSTALL_DIR/include $CFLAGS " \
# CXXFLAGS=" -I$MY_PMIX_INSTALL_DIR/include $CFLAGS " \
# LDFLAGS=" -L$MY_PMIX_INSTALL_DIR/lib $LDFLAGS -lpmix " \
# cmake -G "Unix Makefiles" \
#     -D CMAKE_INSTALL_PREFIX=$LLVM_INSTALL_DIR/release \
#     -D CMAKE_BUILD_TYPE=Release \
#     -D LLVM_ENABLE_ASSERTIONS=Off  \
#     -D CMAKE_C_COMPILER=gcc \
#     -D CMAKE_CXX_COMPILER=g++ \
#     -D PMIX_INCLUDE_DIR:PATH=$MY_PMIX_INSTALL_DIR/include \
#     -D PMIX_LIBRARY_DIR:PATH=$MY_PMIX_INSTALL_DIR/lib \
#     -D PATH_TO_PMIX:PATH=$MY_PMIX_INSTALL_DIR \
#     ../../source/llvm/ \
# && make -j 4 \
# && make check-clang-openmp \
# && make install \
# && echo "SUCCESS: Install=$LLVM_INSTALL_DIR/release"
###


 #
 # DEBUG BUILD (DEVELOPMENT)
 # (Only 'make check-clang-openmp' to speed things up)
 #
cd $LLVM_BASEDIR/
cd build/debug/
echo "CWD: `pwd`"
rm -f  CMakeCache.txt
rm -rf CMakeFiles
CFLAGS=" -I$MY_PMIX_INSTALL_DIR/include $CFLAGS " \
CXXFLAGS=" -I$MY_PMIX_INSTALL_DIR/include $CFLAGS " \
LDFLAGS=" -L$MY_PMIX_INSTALL_DIR/lib $LDFLAGS -lpmix " \
cmake -G "Unix Makefiles" \
    -D CMAKE_INSTALL_PREFIX=$LLVM_INSTALL_DIR/debug \
    -D CMAKE_BUILD_TYPE=Debug \
    -D LLVM_ENABLE_ASSERTIONS=On  \
    -D CMAKE_C_COMPILER=gcc \
    -D CMAKE_CXX_COMPILER=g++ \
    -D PMIX_INCLUDE_DIR:PATH=$MY_PMIX_INSTALL_DIR/include \
    -D PMIX_LIBRARY_DIR:PATH=$MY_PMIX_INSTALL_DIR/lib \
    -D PATH_TO_PMIX:PATH=$MY_PMIX_INSTALL_DIR \
    ../../source/llvm/ \
&& make -j 4 \
&& make check-clang-openmp \
&& make install \
&& echo "SUCCESS: Install=$LLVM_INSTALL_DIR/debug"


time_end=`date`

echo "------------------------------------------------"
echo " Release Install: $LLVM_INSTALL_DIR/release"
echo "   Debug Install: $LLVM_INSTALL_DIR/debug"
echo ""
echo "  Start time: $time_begin"
echo " Finish time: $time_end"
echo "------------------------------------------------"

# make check-all          (run ALL regression tests)
# make check-clang-openmp (run clang OpenMP tests)
