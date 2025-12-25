#! /usr/bin/bash -x

###############################
#
# Install SDL
#
# The script expects to be run from the root of the oolite-msys2 repository.
# It expects SDL to be downloaded and built.
#
###############################

# Guard against nproc failing
num_jobs=$(nproc 2>/dev/null)
if [ -z "$num_jobs" ]; then
    echo "Warning: Could not determine number of processors, using 1 job"
    num_jobs=1
fi

cd SDL-1.2.13 || exit
make -j"$num_jobs" install
