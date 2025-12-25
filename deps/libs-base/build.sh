#! /usr/bin/bash -x

###############################
#
# Configure and build libs-base
#
# The script expects to be run from the root of the oolite-msys2 repository.
# It expects tools-make to be installed, and for libs-base to be downloaded.
#
###############################

# Guard against nproc failing
num_jobs=$(nproc 2>/dev/null)
if [ -z "$num_jobs" ]; then
    echo "Warning: Could not determine number of processors, using 1 job"
    num_jobs=1
fi

# shellcheck source=/dev/null
. /mingw64/share/GNUstep/Makefiles/GNUstep.sh
cd libs-base || exit
# Use OpenStep plist format
sed -i '336 s/NSPropertyListXMLFormat_v1_0/NSPropertyListOpenStepFormat/' Source/NSUserDefaults.m
./configure --disable-xslt
make -j"$num_jobs"
