#! /usr/bin/bash

###############################
#
# Configure and build the Oolite installers
#
# Usage: ./build.sh [release|release-deployment|release-snapshot]
#
# The script expects to be run from the root of the oolite-msys2 repository.
# It expects Oolite to be downloaded and successfully built.
#
###############################

cd oolite || exit

# Guard against nproc failing
num_jobs=$(nproc 2>/dev/null)
if [ -z "$num_jobs" ]; then
    echo "Warning: Could not determine number of processors, using 1 job"
    num_jobs=1
fi

# Modify the Windows installer build targets to stop building Oolite when making the installer.
# We assume Oolite is already built.
# Without this, the installer build target rebuilds Oolite.
sed -i 's/pkg-win: release/pkg-win:/' Makefile
sed -i 's/pkg-win-deployment: release-deployment/pkg-win-deployment:/' Makefile
sed -i 's/pkg-win-snapshot: release-snapshot/pkg-win-snapshot:/' Makefile

# Map the build type to the correct Makefile target
if [ "$1" = "release" ]; then
    make -j"$num_jobs" -f Makefile pkg-win
elif [ "$1" = "release-deployment" ]; then
    make -j"$num_jobs" -f Makefile pkg-win-deployment
elif [ "$1" = "release-snapshot" ]; then
    make -j"$num_jobs" -f Makefile pkg-win-snapshot
else
    echo "Error: Invalid build type. Use release, release-deployment, or release-snapshot"
    exit 1
fi
