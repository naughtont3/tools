#!/bin/bash
#
# RUN THIS FIRST!
#
# TJN: (14dec2017) Adjusted paths for Summitdev
#
# Download and setup the source tree (preparation for build/install)
#

# XXX: EDIT HERE
LLVM_VERSION="release_50"
#LLVM_BASEDIR=/home/tjn/projects/ompi-ecp/source/llvm/$LLVM_VERSION
LLVM_BASEDIR=/ccs/home/naughton/projects.summitdev/ompi-ecp/source/llvm/$LLVM_VERSION
LLVM_INSTALL_DIR=/ccs/proj/stf010/naughton/summitdev/ompi-ecp/install/llvm/$LLVM_VERSION

LLVM_URL=https://github.com/llvm-mirror/llvm.git
LLVM_BRANCH="release_50"

CLANG_URL=https://github.com/llvm-mirror/clang.git
CLANG_BRANCH="release_50"

LOMP_URL=https://github.com/OMPI-X/libomp.git
#LOMP_BRANCH="release_50"
LOMP_BRANCH="gv_pmix"

TSUITE_URL=https://github.com/llvm-mirror/test-suite.git
TSUITE_BRANCH="release_50"

#------------------------------------------------------

time_begin=`date`

echo "LLVM_VERSION=$LLVM_VERSION"
echo "LLVM_BASEDIR=$LLVM_BASEDIR"

mkdir -p $LLVM_BASEDIR/source/
mkdir -p $LLVM_BASEDIR/archive/
mkdir -p $LLVM_BASEDIR/build/
mkdir -p $LLVM_BASEDIR/build/release/
mkdir -p $LLVM_BASEDIR/build/debug/
mkdir -p $LLVM_INSTALL_DIR
mkdir -p $LLVM_INSTALL_DIR/release/
mkdir -p $LLVM_INSTALL_DIR/debug/

#-----------------------------------------
#
# 1. Download 
#
#-----------------------------------------
# Nothing to download (see source below)


#-----------------------------------------
#
# 2. Extract (checkout)
#
#-----------------------------------------

cd $LLVM_BASEDIR/
cd source/

git --version >&  /dev/null
if [ "$?" -ne 0 ] ; then
    echo "ERROR: Missing utility 'git'"
    exit 1
fi

git clone -b $LLVM_BRANCH    $LLVM_URL    llvm

cd $LLVM_BASEDIR/source/llvm/tools/
git clone -b $CLANG_BRANCH   $CLANG_URL   clang

cd $LLVM_BASEDIR/source/llvm/projects/
git clone -b $LOMP_BRANCH    $LOMP_URL    openmp

cd $LLVM_BASEDIR/source/llvm/projects/
git clone -b $TSUITE_BRANCH  $TSUITE_URL  test-suite


#-----------------------------------------
#
# 3. Setup source tree/paths
#
#-----------------------------------------

cd $LLVM_BASEDIR/
cd source/
#ln -sr clang         llvm/tools/clang
#ln -sr openmp        llvm/projects/openmp
#ln -sr test-suite    llvm/projects/test-suite

##
# Make symlink into the specific git repos under source/llvm/ tree
# It seems LLVM wants the directories to reside within the tree,
# no symlinks to out of tree directories (at least in my build).
##
ln -s llvm/tools/clang          clang
ln -s llvm/projects/openmp      openmp
ln -s llvm/projects/test-suite  test-suite


time_end=`date`

# NOW READY TO RUN THE 'Configure/Build' script ('llvm_build*.sh')
echo "------------------------------------------------"
echo " INFO: Ready to run 'llvm_build*.sh'"
echo ""
echo "  Start time: $time_begin"
echo " Finish time: $time_end"
echo "------------------------------------------------"

exit 0
