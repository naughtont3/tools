
 #
 # GNU Compiler/Development environment settings on SUMMITDEV
 #

module load gcc
module load cmake
module unload spectrum-mpi

if [ ! `which cc` ]; then
    echo "Error: unable to locate 'cc' in PATH"
fi

 # NOTE: 
 #  + Separate commands to capture return values
 #  + GNU GCC supports the '--version' option!
 #  + Example of expected output:
 #      gcc (GCC) 4.1.2 20070115 (prerelease) (SUSE Linux)
tmp_rslt=`cc --version 2>&1`  
ret_rslt=$?
tmp_status=`echo $tmp_rslt | grep GCC`
ret_status=$?

if  [ "$ret_rslt" == 0 ] && [ "$ret_status" == 0 ]; then
    echo "Info: SUCCESS - found expected gcc compiler"
else
    echo "Warning: 'cc' does not appear to be GCC compiler"
fi

#  #
#  # XXX: Ensure that our 'CC' environment var points to 'cc',
#  #      this is necessary for case where we source this script
#  #      before building software that might check the EnvVar CC
#  #      to select a default.  Ultimatley, it will point to 'gcc'
#  #      but we want to go through the Jaguar wrapper (cc).
#  # 
# export CC=cc
# export CXX=CC
# export F77=ftn
# #export FC=???

 # 
 # Show version info for what we have loaded/available now...
 #
echo -n "   " ; autoconf --version | head -1
echo -n "   " ; automake --version | head -1
echo -n "   " ; gcc      --version | head -1
module list
