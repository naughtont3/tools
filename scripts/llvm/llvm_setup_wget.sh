#!/bin/bash
#
# RUN THIS FIRST!
#
# Download and setup the source tree (preparation for build/install)
#

# XXX: EDIT HERE
LLVM_VERSION=5.0.1
#LLVM_BASEDIR=/home/tjn/projects/ompi-ecp/source/llvm/$LLVM_VERSION
LLVM_BASEDIR=/home/tjn/projects/ompi-ecp/source/llvm-vanilla/$LLVM_VERSION

#------------------------------------------------------

echo "LLVM_VERSION=$LLVM_VERSION"
echo "LLVM_BASEDIR=$LLVM_BASEDIR"

mkdir -p $LLVM_BASEDIR/source/
mkdir -p $LLVM_BASEDIR/archive/
mkdir -p $LLVM_BASEDIR/build/
mkdir -p $LLVM_BASEDIR/build/release/
mkdir -p $LLVM_BASEDIR/build/debug/
mkdir -p $LLVM_BASEDIR/install/
mkdir -p $LLVM_BASEDIR/install/release/
mkdir -p $LLVM_BASEDIR/install/debug/

#-----------------------------------------
#
# 1. Download
#
#-----------------------------------------

cd $LLVM_BASEDIR/
cd archive/
wget http://releases.llvm.org/$LLVM_VERSION/llvm-$LLVM_VERSION.src.tar.xz
wget http://releases.llvm.org/$LLVM_VERSION/cfe-$LLVM_VERSION.src.tar.xz
wget http://releases.llvm.org/$LLVM_VERSION/compiler-rt-$LLVM_VERSION.src.tar.xz
wget http://releases.llvm.org/$LLVM_VERSION/libcxx-$LLVM_VERSION.src.tar.xz
wget http://releases.llvm.org/$LLVM_VERSION/libcxxabi-$LLVM_VERSION.src.tar.xz
wget http://releases.llvm.org/$LLVM_VERSION/lld-$LLVM_VERSION.src.tar.xz
wget http://releases.llvm.org/$LLVM_VERSION/openmp-$LLVM_VERSION.src.tar.xz
wget http://releases.llvm.org/$LLVM_VERSION/polly-$LLVM_VERSION.src.tar.xz
wget http://releases.llvm.org/$LLVM_VERSION/test-suite-$LLVM_VERSION.src.tar.xz
####
# SKIPPING THESE FOR NOW:
# wget http://releases.llvm.org/$LLVM_VERSION/libunwind-$LLVM_VERSION.src.tar.xz
# wget http://releases.llvm.org/$LLVM_VERSION/lldb-$LLVM_VERSION.src.tar.xz
# wget http://releases.llvm.org/$LLVM_VERSION/clang-tools-extra-$LLVM_VERSION.src.tar.xz
####


#-----------------------------------------
#
# 2. Extract
#
#-----------------------------------------

cd $LLVM_BASEDIR/
cd source/
tar -xf ../archive/llvm-$LLVM_VERSION.src.tar.xz
tar -xf ../archive/cfe-$LLVM_VERSION.src.tar.xz
tar -xf ../archive/compiler-rt-$LLVM_VERSION.src.tar.xz
tar -xf ../archive/libcxx-$LLVM_VERSION.src.tar.xz
tar -xf ../archive/libcxxabi-$LLVM_VERSION.src.tar.xz
tar -xf ../archive/lld-$LLVM_VERSION.src.tar.xz
tar -xf ../archive/openmp-$LLVM_VERSION.src.tar.xz
tar -xf ../archive/polly-$LLVM_VERSION.src.tar.xz
tar -xf ../archive/test-suite-$LLVM_VERSION.src.tar.xz
####
# SKIPPING THESE FOR NOW:
# tar -xf ../archive/libunwind-$LLVM_VERSION.src.tar.xz
# tar -xf ../archive/lldb-$LLVM_VERSION.src.tar.xz
# tar -xf ../archive/clang-tools-extra-$LLVM_VERSION.src.tar.xz
####



#-----------------------------------------
#
# 3. Setup source tree/paths
#
#-----------------------------------------

cd $LLVM_BASEDIR/
cd source/
ln -s llvm-$LLVM_VERSION.src             llvm
# ln -sr cfe-$LLVM_VERSION.src             llvm/tools/clang
# ln -sr lld-$LLVM_VERSION.src             llvm/tools/lld
# ln -sr polly-$LLVM_VERSION.src           llvm/tools/polly
# ln -sr compiler-rt-$LLVM_VERSION.src     llvm/projects/compiler-rt
# ln -sr openmp-$LLVM_VERSION.src          llvm/projects/openmp
# ln -sr libcxx-$LLVM_VERSION.src          llvm/projects/libcxx
# ln -sr libcxxabi-$LLVM_VERSION.src       llvm/projects/libcxxabi
# ln -sr test-suite-$LLVM_VERSION.src      llvm/projects/test-suite
####
# SKIPPING THESE FOR NOW:
# ln -sr libunwind-$LLVM_VERSION.src         ???
# ln -sr lldb-$LLVM_VERSION.src              ???
# ln -sr clang-tools-extra-$LLVM_VERSION.src ???
####
mv cfe-$LLVM_VERSION.src             llvm/tools/clang
mv lld-$LLVM_VERSION.src             llvm/tools/lld
mv polly-$LLVM_VERSION.src           llvm/tools/polly
mv compiler-rt-$LLVM_VERSION.src     llvm/projects/compiler-rt
mv openmp-$LLVM_VERSION.src          llvm/projects/openmp
mv libcxx-$LLVM_VERSION.src          llvm/projects/libcxx
mv libcxxabi-$LLVM_VERSION.src       llvm/projects/libcxxabi
mv test-suite-$LLVM_VERSION.src      llvm/projects/test-suite


# NOW READY TO RUN THE 'Configure/Build' script ('llvm_build.sh')
echo "------------------------------------------------"
echo " INFO: Ready to run 'llvm_build.sh'"
echo "------------------------------------------------"

exit 0
