#!/bin/bash
#
# TJN: (26jan2018) Modified version of OMPIX build script for OpenMPI
#      to build **just** OMPI.  It uses tarballs, but I left the code
#      for using git repos commented out.  I removed all other bits
#      to make it simpler for the "just OMPI" case.
#
#      See the 'scripts/ompix/' subdir for more elaborate version.
#      https://github.com/OMPI-X/tools.git
#
# NOTE: See the 'XXX: EDIT HERE' marks for items to change/customize.
#
######
#
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
# XXX: EDIT HERE
#source_base_dir=/home/tjn/projects/ompi-ecp/source
#install_base_dir=/home/tjn/projects/ompi-ecp/install
source_base_dir=/tmp/ompi-test/source
install_base_dir=/tmp/ompi-test/install

################################

# OpenMPI
# XXX: EDIT HERE
ompi_version=3.0.0
ompi_archive=https://github.com/open-mpi/ompi/archive/v${ompi_version}.tar.gz
# TJN: (26jan2018) Default to tarball but leaving code (commented) for git
#ompi_version=git-br-master
#ompi_repo=https://github.com/open-mpi/ompi.git
#ompi_repo_branch=master


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
    echo "    -O       SKIP (O)MPI/ORTE   ALL"
    echo "    -o       SKIP (O)MPI/ORTE   download"
    echo ""
    echo "    -h       Print this help info"
    echo "    -d       Debug mode"
    echo ""
}

###
# MAIN
###

SKIP_OMPI=0             # -O  skip (O)MPI/ORTE
SKIP_OMPI_DL=0          # -o  skip (O)MPI/ORTE download

opt_showhelp=0          # -h  show usage/help
DEBUG=0                 # -d  debug mode

orig_dir=$PWD
time_begin=`date`

#
# Process ARGV/cmd-line
# TODO: ADD SUPPORT FOR '--skip-<pkgname>'
#
OPTIND=1
while getopts hdOo opt ; do
    case "$opt" in
        O)  SKIP_OMPI=1;;               # -O  skip (O)MPI/ORTE
        o)  SKIP_OMPI_DL=1;;            # -O  skip (O)MPI/ORTE download
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
    echo "DBG:       SKIP_OMPI = '$SKIP_OMPI'"
    echo "DBG:    SKIP_OMPI_DL = '$SKIP_OMPI_DL'"
    echo ""
    echo "DBG:     ompi_version = $ompi_version"
    echo "DBG:    ompi_archive  = $ompi_archive"
#    echo "DBG:        ompi_repo = $ompi_repo"
#    echo "DBG: ompi_repo_branch = $ompi_repo_branch"
    echo "DBG:       ******************"
fi

if [ $opt_showhelp -ne 0 ]; then
    usage
    exit 0
fi

#-----

mkdir -p $source_base_dir

# OMPI CONFIGURE FOR DEBUG BUILD
#    ./configure \
#           --enable-debug \
#           --enable-debug \
#           --with-devel-headers \
#        --enable-oshmem \
#        --prefix=${OMPI_INSTALL_DIR} \

# OpenMPI (ORTE) (tar.gz)
if [ $SKIP_OMPI = 0 ] ; then
    echo "BUILD OMPI"

    export OMPI_ARCHIVE_URL=$ompi_archive && \
    export OMPI_SOURCE_DIR=$source_base_dir/ompi-${ompi_version} && \
    export OMPI_INSTALL_DIR=$install_base_dir && \
    export OMPI_ARCHIVE_FILE=`echo "${OMPI_ARCHIVE_URL##*/}"` && \
    if [ $SKIP_OMPI_DL = 0 ] ; then \
        mkdir -p $OMPI_SOURCE_DIR && \
        cd $OMPI_SOURCE_DIR && \
        wget --quiet $OMPI_ARCHIVE_URL && \
        tar -zxf ${OMPI_ARCHIVE_FILE} -C ${OMPI_SOURCE_DIR} --strip-components=1 && \
        echo "OMPI DOWNLOAD STEP DONE" ; \
    fi && \
    cd ${OMPI_SOURCE_DIR} && \
    ./autogen.pl && \
    ./configure \
        --enable-oshmem \
        --prefix=${OMPI_INSTALL_DIR} \
        && \
    make -j 4 && \
    make install || die "OMPI failed"

    echo "   OMPI_SOURCE_DIR: $OMPI_SOURCE_DIR"
    echo "  OMPI_INSTALL_DIR: $OMPI_INSTALL_DIR"
#    echo "   NOTE - OMPI: ENABLED DEBUG BUILD"

else
    echo "SKIP OMPI"
    export OMPI_SOURCE_DIR=$source_base_dir/ompi-${ompi_version}
    export OMPI_INSTALL_DIR=$install_base_dir
fi

# # OpenMPI (ORTE) (git)
# if [ $SKIP_OMPI = 0 ] ; then
#     echo "BUILD OMPI"
#
#     export OMPI_REPO_URL=$ompi_repo && \
#     export OMPI_REPO_BRANCH=$ompi_repo_branch && \
#     export OMPI_SOURCE_DIR=$source_base_dir/ompi-${ompi_version} && \
#     export OMPI_INSTALL_DIR=$install_base_dir && \
#     if [ $SKIP_OMPI_DL = 0 ] ; then \
#         mkdir -p $OMPI_SOURCE_DIR && \
#         cd $OMPI_SOURCE_DIR && \
#         git clone -b ${OMPI_REPO_BRANCH} ${OMPI_REPO_URL} ${OMPI_SOURCE_DIR} && \
#         echo "OMPI DOWNLOAD STEP DONE" ; \
#     fi && \
#     cd ${OMPI_SOURCE_DIR} && \
#     ./autogen.pl && \
#     ./configure \
#         --enable-oshmem \
#         --prefix=${OMPI_INSTALL_DIR} \
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

