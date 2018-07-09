#!/bin/bash
# Build following for OMPIX development, with PMIX and OMPI debug enabled.
#   - libevent (tar.gz)
#   - pmix (git)
#   - ompi (git)
#   - MOC (git)
#     mpi+omp coordination library
#
# TJN: Mon Dec  4 16:33:24 EST 2017

#
# NOTE: If EnvVar 'GITHUB_TOKEN' is set, will use Personal Access Token
#       for passwordless access to the ORNL-Languages Git repo.
# https://help.github.com/articles/creating-an-access-token-for-command-line-use
#

####
# BUILD PREREQS
#   - libnuma-dev
#   - bfd
#   - binutils-dev
#   - binutils-multiarch-dev
#   - flex
#   - bison
#   - gcc
#   - g++
#   - autoconf
#   - automake
#   - libtool
#   - linux-headers  (XPMEM)
#   - libelf-dev     (gelf.h by OSHMEM)
#   - libibverbs-dev (verbs.h UCX)
#   - librdmacm-dev  (rdma/rdma_cma.h UCX)
####

#
# Source/Install directory
# (NOTE: We download/unpack software in the "$source_base_dir/")
#
#source_base_dir=/home/tjn/projects/ompi-ecp/source
#install_base_dir=/home/tjn/projects/ompi-ecp/install
source_base_dir=/ccs/home/naughton/projects.summit/ompix/source
install_base_dir=/ccs/proj/stf010/naughton/summit/ompi-ecp/install

####

#########
# ENV Vars:
#   LIBEVENT_SOURCE_DIR
#   LIBEVENT_INSTALL_DIR
#
#   PMIX_SOURCE_DIR
#   PMIX_INSTALL_DIR
#
#   OMPI_SOURCE_DIR
#   OMPI_INSTALL_DIR
#
#   MOC_SOURCE_DIR
#   MOC_INSTALL_DIR
#########


# Quick Hack to autoset envvar if magic file exists
if [ -f "mytoken" ] ; then
    export GITHUB_TOKEN=$(cat mytoken)
fi

# Libevent
libevent_version=2.1.8-stable
libevent_archive=https://github.com/libevent/libevent/releases/download/release-${libevent_version}/libevent-${libevent_version}.tar.gz

# PMIX
##pmix_version=2.0.2
##pmix_archive=https://github.com/pmix/pmix/releases/download/v${pmix_version}/pmix-${pmix_version}.tar.gz
pmix_version=git-br-master
pmix_repo=https://github.com/pmix/pmix.git
pmix_repo_branch=master

# OpenMPI
##ompi_version=3.0.0
##ompi_archive=https://github.com/open-mpi/ompi/archive/v${ompi_version}.tar.gz
ompi_version=git-br-master
ompi_repo=https://github.com/open-mpi/ompi.git
ompi_repo_branch=master

# MOC (git)
moc_version=git-br-master
if [ -z "$GITHUB_TOKEN" ]; then
    moc_repo=https://github.com/OMPI-X/MOC.git
else
    moc_repo=https://${GITHUB_TOKEN}:x-oauth-basic@github.com/OMPI-X/MOC.git
fi
moc_repo_branch=master

# # XPMEM
# xpmem_version=git-br-master
# xpmem_repo=https://github.com/hjelmn/xpmem
# xpmem_repo_branch=master

# # UCX
# ucx_version=git-br-master
# ucx_repo=https://github.com/openucx/ucx.git
# ucx_repo_branch=master

#####################

die () {
    local emsg
    emsg="$@"

    echo "ERROR: $emsg"
    exit 1
}

usage () {
    echo "Usage: $0  [-h]"
    echo " OPTIONS:"
    echo "    -L       SKIP (L)ibevent   ALL"
    echo "    -l       SKIP (l)ibevent   download"
    echo "    -P       SKIP (P)MIx   ALL"
    echo "    -p       SKIP (P)MIx   download"
    echo "    -O       SKIP (O)MPI/ORTE   ALL"
    echo "    -o       SKIP (O)MPI/ORTE   download"
    echo "    -M       SKIP (M)OC   ALL"
    echo "    -m       SKIP (M)OC   download"
#    echo "    -X       SKIP (X)PMEM"
#    echo "    -U       SKIP (U)CX"
    echo ""
    echo "    -h       Print this help info"
    echo "    -d       Debug mode"
    echo ""
    echo " NOTE: If EnvVar 'GITHUB_TOKEN' is set, script will use a"
    echo "       Github 'Personal Access Token' for passwordless access"
    echo "       to the ORNL-Languages Git repo checkout."
    echo "       Otherwise must manually enter username/pass when prompted."
    echo " See Github docs:"
    echo "  https://help.github.com/articles/creating-an-access-token-for-command-line-use"
    echo ""
}

###
# MAIN
###

SKIP_LIBEVENT=0         # -L  skip (L)ibevent
SKIP_LIBEVENT_DL=0      # -l  skip (L)ibevent  download
SKIP_PMIX=0             # -P  skip (P)MIx
SKIP_PMIX_DL=0          # -p  skip (P)MIx      download
SKIP_OMPI=0             # -O  skip (O)MPI/ORTE
SKIP_OMPI_DL=0          # -o  skip (O)MPI/ORTE download
SKIP_MOC=0              # -M  skip (M)OC
SKIP_MOC_DL=0           # -m  skip (M)OC       download
#SKIP_XPMEM=0            # -X  skip (X)PMEM
#SKIP_UCX=0              # -U  skip (U)CX

opt_showhelp=0          # -h  show usage/help
DEBUG=0                 # -d  debug mode

orig_dir=$PWD
time_begin=`date`

#
# Process ARGV/cmd-line
# TODO: ADD SUPPORT FOR '--skip-<pkgname>'
#
OPTIND=1
while getopts hdLPOXUSlpom opt ; do
    case "$opt" in
        L)  SKIP_LIBEVENT=1;;           # -L  skip (L)ibevent
        l)  SKIP_LIBEVENT_DL=1;;        # -l  skip (L)ibevent  download
        P)  SKIP_PMIX=1;;               # -P  skip (P)MIx
        p)  SKIP_PMIX_DL=1;;            # -p  skip (P)MIx      download
        O)  SKIP_OMPI=1;;               # -O  skip (O)MPI/ORTE
        o)  SKIP_OMPI_DL=1;;            # -O  skip (O)MPI/ORTE download
        M)  SKIP_MOC=1;;                # -M  skip (M)OC
        m)  SKIP_MOC_DL=1;;             # -M  skip (M)OC       download
#        X)  SKIP_XPMEM=1;;              # -X  skip (X)PMEM
#        U)  SKIP_UCX=1;;                # -U  skip (U)CX
        h)  opt_showhelp=1;;            # -h  show usage/help
        d)  DEBUG=1;;                   # -d  debug mode
    esac
done

shift $(($OPTIND - 1))
if [ "$1" = '--' ]; then
    shift
fi


if [ $DEBUG -ne 0 ] ; then
    echo "DBG:       *** DEBUG MODE ***"
    echo "DBG:   SKIP_LIBEVENT = '$SKIP_LIBEVENT'"
    echo "DBG: SKIP_LIBEVENT_DL = '$SKIP_LIBEVENT_DL'"
    echo "DBG:       SKIP_PMIX = '$SKIP_PMIX'"
    echo "DBG:    SKIP_PMIX_DL = '$SKIP_PMIX_DL'"
    echo "DBG:       SKIP_OMPI = '$SKIP_OMPI'"
    echo "DBG:    SKIP_OMPI_DL = '$SKIP_OMPI_DL'"
    echo "DBG:        SKIP_MOC = '$SKIP_MOC'"
    echo "DBG:     SKIP_MOC_DL = '$SKIP_MOC_DL'"
#    echo "DBG:      SKIP_XPMEM = '$SKIP_XPMEM'"
#    echo "DBG:        SKIP_UCX = '$SKIP_UCX'"
    echo ""
    echo "DBG: libevent_version = $libevent_version"
    echo "DBG: libevent_archive = $libevent_archive"
    echo ""
    echo "DBG:     pmix_version = $pmix_version"
    echo "DBG:     pmix_archive = $pmix_archive"
    echo ""
    echo "DBG:     ompi_version = $ompi_version"
    echo "DBG:        ompi_repo = $ompi_repo"
    echo "DBG: ompi_repo_branch = $ompi_repo_branch"
    echo ""
    echo "DBG:      moc_version = $moc_version"
    echo "DBG:         moc_repo = $moc_repo"
    echo "DBG:  moc_repo_branch = $moc_repo_branch"
    echo ""
#    echo "DBG:     xpmem_version = $xpmem_version"
#    echo "DBG:        xpmem_repo = $xpmem_repo"
#    echo "DBG: xpmem_repo_branch = $xpmem_repo_branch"
#    echo ""
#    echo "DBG:      ucx_version = $ucx_version"
#    echo "DBG:         ucx_repo = $ucx_repo"
#    echo "DBG:  ucx_repo_branch = $ucx_repo_branch"
#    echo ""
    echo "DBG:       ******************"
fi

if [ $opt_showhelp -ne 0 ]; then
    usage
    exit 0
fi

#-----

mkdir -p $source_base_dir

# Libevent (tar.gz)
if [ $SKIP_LIBEVENT = 0 ] ; then
    echo "BUILD LIBEVENT"

    export LIBEVENT_ARCHIVE_URL=$libevent_archive && \
    export LIBEVENT_SOURCE_DIR=$source_base_dir/libevent-${libevent_version} && \
    export LIBEVENT_INSTALL_DIR=$install_base_dir && \
    export LIBEVENT_ARCHIVE_FILE=`echo "${LIBEVENT_ARCHIVE_URL##*/}"` && \
    if [ $SKIP_LIBEVENT_DL = 0 ] ; then \
        mkdir -p $LIBEVENT_SOURCE_DIR && \
        cd $LIBEVENT_SOURCE_DIR && \
        wget --quiet $LIBEVENT_ARCHIVE_URL && \
        tar -zxf ${LIBEVENT_ARCHIVE_FILE} -C ${LIBEVENT_SOURCE_DIR} --strip-components=1 && \
        echo "LIBEVENT DOWNLOAD STEP DONE" ; \
    fi && \
    cd ${LIBEVENT_SOURCE_DIR} && \
    ./configure \
        --prefix=${LIBEVENT_INSTALL_DIR} \
        && \
    make -j 4 && \
    make install || die "Libevent failed"

    echo "   LIBEVENT_SOURCE_DIR: $LIBEVENT_SOURCE_DIR"
    echo "  LIBEVENT_INSTALL_DIR: $LIBEVENT_INSTALL_DIR"

else
    echo "SKIP LIBEVENT"
    export LIBEVENT_SOURCE_DIR=$source_base_dir/libevent-${libevent_version}
    export LIBEVENT_INSTALL_DIR=$install_base_dir
fi


# # PMIX (tar.gz)
# if [ $SKIP_PMIX = 0 ] ; then
#     echo "BUILD PMIX"
#
#     export PMIX_ARCHIVE_URL=$pmix_archive && \
#     export PMIX_SOURCE_DIR=$source_base_dir/pmix-${pmix_version} && \
#     export PMIX_INSTALL_DIR=$install_base_dir && \
#     export PMIX_ARCHIVE_FILE=`echo "${PMIX_ARCHIVE_URL##*/}"` && \
#     if [ $SKIP_PMIX_DL = 0 ] ; then \
#         mkdir -p $PMIX_SOURCE_DIR && \
#         cd $PMIX_SOURCE_DIR && \
#         wget --quiet $PMIX_ARCHIVE_URL && \
#         tar -zxf ${PMIX_ARCHIVE_FILE} -C ${PMIX_SOURCE_DIR} --strip-components=1 && \
#         echo "PMIX DOWNLOAD STEP DONE" ; \
#     fi && \
#     cd ${PMIX_SOURCE_DIR} && \
#     ./autogen.pl && \
#     ./configure \
#             --enable-debug \
#         --prefix=${PMIX_INSTALL_DIR} \
#         --with-libevent=${LIBEVENT_INSTALL_DIR} \
#         && \
#     make -j 4 && \
#     make install || die "PMIX failed"
#
#     echo "   PMIX_SOURCE_DIR: $PMIX_SOURCE_DIR"
#     echo "  PMIX_INSTALL_DIR: $PMIX_INSTALL_DIR"
#     echo "   NOTE - PMIX: ENABLED DEBUG BUILD"
#
# else
#     echo "SKIP PMIX"
#     export PMIX_SOURCE_DIR=$source_base_dir/pmix-${pmix_version}
#     export PMIX_INSTALL_DIR=$install_base_dir
# fi

# PMIX (git)
if [ $SKIP_PMIX = 0 ] ; then
    echo "BUILD PMIX"

    export PMIX_REPO_URL=$pmix_repo && \
    export PMIX_REPO_BRANCH=$pmix_repo_branch && \
    export PMIX_SOURCE_DIR=$source_base_dir/pmix-${pmix_version} && \
    export PMIX_INSTALL_DIR=$install_base_dir && \
    if [ $SKIP_PMIX_DL = 0 ] ; then \
        mkdir -p $PMIX_SOURCE_DIR && \
        cd $PMIX_SOURCE_DIR && \
        git clone -b ${PMIX_REPO_BRANCH} ${PMIX_REPO_URL} ${PMIX_SOURCE_DIR} && \
        echo "PMIX DOWNLOAD STEP DONE" ; \
    fi && \
    cd ${PMIX_SOURCE_DIR} && \
    ./autogen.pl && \
    ./configure \
           --enable-debug \
        --prefix=${PMIX_INSTALL_DIR} \
        --with-libevent=${LIBEVENT_INSTALL_DIR} \
        LDFLAGS=-lpthread \
        && \
    make -j 4 && \
    make install || die "PMIX failed"

    echo "   PMIX_SOURCE_DIR: $PMIX_SOURCE_DIR"
    echo "  PMIX_INSTALL_DIR: $PMIX_INSTALL_DIR"
    echo "   NOTE - PMIX: ENABLED DEBUG BUILD"

else
    echo "SKIP PMIX"
    export PMIX_SOURCE_DIR=$source_base_dir/pmix-${pmix_version}
    export PMIX_INSTALL_DIR=$install_base_dir
fi


###
# # OpenMPI (ORTE) (tar.gz)
# if [ $SKIP_OMPI = 0 ] ; then
#     echo "BUILD OMPI"
#
#     export OMPI_ARCHIVE_URL=$ompi_archive && \
#     export OMPI_SOURCE_DIR=$source_base_dir/ompi-${ompi_version} && \
#     export OMPI_INSTALL_DIR=$install_base_dir && \
#     export OMPI_ARCHIVE_FILE=`echo "${OMPI_ARCHIVE_URL##*/}"` && \
#     if [ $SKIP_OMPI_DL = 0 ] ; then \
#         mkdir -p $OMPI_SOURCE_DIR && \
#         cd $OMPI_SOURCE_DIR && \
#         wget --quiet $OMPI_ARCHIVE_URL && \
#         tar -zxf ${OMPI_ARCHIVE_FILE} -C ${OMPI_SOURCE_DIR} --strip-components=1 && \
#         echo "OMPI DOWNLOAD STEP DONE" ; \
#     fi && \
#     cd ${OMPI_SOURCE_DIR} && \
#     ./autogen.pl -no-oshmem && \
#     ./configure \
#            --enable-debug \
#            --with-devel-headers \
#         --prefix=${OMPI_INSTALL_DIR} \
#         --with-pmix=${PMIX_INSTALL_DIR} \
#         --with-libevent=${LIBEVENT_INSTALL_DIR} \
#         && \
#     make -j 4 && \
#     make install || die "OMPI failed"
#
#     echo "   OMPI_SOURCE_DIR: $OMPI_SOURCE_DIR"
#     echo "  OMPI_INSTALL_DIR: $OMPI_INSTALL_DIR"
#     echo "   NOTE - OMPI: ENABLED DEBUG BUILD"
#
# else
#     echo "SKIP OMPI"
#     export OMPI_SOURCE_DIR=$source_base_dir/ompi-${ompi_version}
#     export OMPI_INSTALL_DIR=$install_base_dir
# fi
###

# OpenMPI (ORTE) (git)
if [ $SKIP_OMPI = 0 ] ; then
    echo "BUILD OMPI"

    export OMPI_REPO_URL=$ompi_repo && \
    export OMPI_REPO_BRANCH=$ompi_repo_branch && \
    export OMPI_SOURCE_DIR=$source_base_dir/ompi-${ompi_version} && \
    export OMPI_INSTALL_DIR=$install_base_dir && \
    if [ $SKIP_OMPI_DL = 0 ] ; then \
        mkdir -p $OMPI_SOURCE_DIR && \
        cd $OMPI_SOURCE_DIR && \
        git clone -b ${OMPI_REPO_BRANCH} ${OMPI_REPO_URL} ${OMPI_SOURCE_DIR} && \
        echo "OMPI DOWNLOAD STEP DONE" ; \
    fi && \
    cd ${OMPI_SOURCE_DIR} && \
    ./autogen.pl -no-oshmem && \
    ./configure \
           --enable-debug \
           --with-devel-headers \
        --prefix=${OMPI_INSTALL_DIR} \
        --with-pmix=${PMIX_INSTALL_DIR} \
        --with-libevent=${LIBEVENT_INSTALL_DIR} \
        LDFLAGS=-lpthread \
        && \
    make -j 4 && \
    make install || die "OMPI failed"

    echo "   OMPI_SOURCE_DIR: $OMPI_SOURCE_DIR"
    echo "  OMPI_INSTALL_DIR: $OMPI_INSTALL_DIR"
    echo "   NOTE - OMPI: ENABLED DEBUG BUILD"

else
    echo "SKIP OMPI"
    export OMPI_SOURCE_DIR=$source_base_dir/ompi-${ompi_version}
    export OMPI_INSTALL_DIR=$install_base_dir
fi


# MOC (git)
if [ $SKIP_MOC = 0 ] ; then
    echo "BUILD MOC"

    export MOC_REPO_URL=$moc_repo && \
    export MOC_REPO_BRANCH=$moc_repo_branch && \
    export MOC_SOURCE_DIR=$source_base_dir/moc-${moc_version} && \
    export MOC_INSTALL_DIR=$install_base_dir && \
    if [ $SKIP_MOC_DL = 0 ] ; then \
        mkdir -p $MOC_SOURCE_DIR && \
        cd $MOC_SOURCE_DIR && \
        git clone -b ${MOC_REPO_BRANCH} ${MOC_REPO_URL} ${MOC_SOURCE_DIR} && \
        echo "MOC DOWNLOAD STEP DONE" ; \
    fi && \
    cd ${MOC_SOURCE_DIR} && \
    echo "TODO: ./configure --prefix=${MOC_INSTALL_DIR} --with-mpi=${OMPI_INSTALL_DIR} --with-pmix=${PMIX_INSTALL_DIR}" \
        && \
    ./autogen.sh && \
    ./configure \
        --prefix=${MOC_INSTALL_DIR} \
        --with-mpi=${OMPI_INSTALL_DIR} \
        --with-pmix=${PMIX_INSTALL_DIR} \
        && \
    make -j 4 && \
    make install || die "MOC failed"

    echo "   MOC_SOURCE_DIR: $MOC_SOURCE_DIR"
    echo "  MOC_INSTALL_DIR: $MOC_INSTALL_DIR"
    echo "   NOTE - MOC: ENABLED DEBUG BUILD"

else
    echo "SKIP MOC"
    export MOC_SOURCE_DIR=$source_base_dir/moc-${moc_version}
    export MOC_INSTALL_DIR=$install_base_dir
fi


###
# # XPMEM (git)
# if [ $SKIP_XPMEM = 0 ] ; then
#     echo "BUILD XPMEM"
#
#     export XPMEM_REPO_URL=$xpmem_repo && \
#     export XPMEM_REPO_BRANCH=$xpmem_repo_branch && \
#     export XPMEM_SOURCE_DIR=$source_base_dir/xpmem-${xpmem_version} && \
#     export XPMEM_INSTALL_DIR=$install_base_dir && \
#     mkdir -p $XPMEM_SOURCE_DIR && \
#     cd $XPMEM_SOURCE_DIR && \
#     git clone -b ${XPMEM_REPO_BRANCH} ${XPMEM_REPO_URL} ${XPMEM_SOURCE_DIR} && \
#     cd ${XPMEM_SOURCE_DIR} && \
#     ./autogen.sh && \
#     ./configure \
#         --prefix=${XPMEM_INSTALL_DIR}  \
#         --with-default-prefix=${XPMEM_INSTALL_DIR} \
#         --with-module=/usr/src/linux-headers-$(uname -r) \
#         && \
#     make -j 4 \
#      || die "XPMEM failed" \
#      && make install || echo "XPMEM install problem (continue anyway)"
#
#     echo "   XPMEM_SOURCE_DIR: $XPMEM_SOURCE_DIR"
#     echo "  XPMEM_INSTALL_DIR: $XPMEM_INSTALL_DIR"
#     echo "TODO: LOAD XPMEM KERNEL MODULE!"
#
# else
#     echo "SKIP XPMEM"
#     export XPMEM_SOURCE_DIR=$source_base_dir/xpmem-${xpmem_version}
#     export XPMEM_INSTALL_DIR=$install_base_dir
#     echo "TODO: LOAD XPMEM KERNEL MODULE!"
# fi
#
# TJN: UCX - if using 'xpmem' add following to UCX configure
#        --with-xpmem=${XPMEM_INSTALL_DIR} \
###


# # UCX (git)
# if [ $SKIP_UCX = 0 ] ; then
#     echo "BUILD UCX"
#
#     export UCX_REPO_URL=$ucx_repo && \
#     export UCX_REPO_BRANCH=$ucx_repo_branch && \
#     export UCX_SOURCE_DIR=$source_base_dir/ucx-${ucx_version} && \
#     export UCX_INSTALL_DIR=$install_base_dir && \
#     mkdir -p $UCX_SOURCE_DIR && \
#     cd $UCX_SOURCE_DIR && \
#     git clone -b ${UCX_REPO_BRANCH} ${UCX_REPO_URL} ${UCX_SOURCE_DIR} && \
#     cd ${UCX_SOURCE_DIR} && \
#     ./autogen.sh && \
#     ./configure \
#         --prefix=${UCX_INSTALL_DIR} \
#         && \
#     make -j 4 && \
#     make install || die "UCX failed"
#
#     echo "   UCX_SOURCE_DIR: $UCX_SOURCE_DIR"
#     echo "  UCX_INSTALL_DIR: $UCX_INSTALL_DIR"
#
# else
#     echo "SKIP UCX"
#     export UCX_SOURCE_DIR=$source_base_dir/ucx-${ucx_version}
#     export UCX_INSTALL_DIR=$install_base_dir
# fi


#-----
time_end=`date`
cd $orig_dir

echo "##################################################################"
echo "  Source dir: $source_base_dir/"
echo " Install dir: $install_base_dir/"
echo ""
echo "  Start time: $time_begin"
echo " Finish time: $time_end"
echo "##################################################################"

