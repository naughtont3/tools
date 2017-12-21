
 #
 # OMPI-X environment settings
 #
 # TJN - Mon Dec  4 16:18:15 EST 2017
 #

basedir="$HOME/projects/ompi-ecp/install"
ompix_lib_path="${basedir}/lib"
ompix_inc_path="${basedir}/include"
ompix_bin_path="${basedir}/bin"

#### END CONFIG ####

if ! `echo $PATH | grep -q ${ompix_bin_path}` ; then
    export PATH="${ompix_bin_path}:$PATH"
fi

if [ "x$LD_LIBRARY_PATH" == "x" ] ; then
    export LD_LIBRARY_PATH="${ompix_lib_path}"
else
    if ! `echo $LD_LIBRARY_PATH | grep -q ${ompix_lib_path}` ; then
        export LD_LIBRARY_PATH="${ompix_lib_path}:$LD_LIBRARY_PATH"
    fi
fi

if [ "x$CFLAGS" == "x" ] ; then
    export CFLAGS=" -I${ompix_inc_path} "
else
    if ! `echo $CFLAGS| grep -q ${ompix_inc_path}` ; then
        export CFLAGS=" -I${ompix_inc_path} $CFLAGS "
    fi
fi

if [ "x$LDFLAGS" == "x" ] ; then
    export LDFLAGS=" -L${ompix_lib_path} "
else
    if ! `echo $LDFLAGS| grep -q ${ompix_lib_path}` ; then
        export LDFLAGS=" -L${ompix_lib_path} $LDFLAGS "
    fi
fi

