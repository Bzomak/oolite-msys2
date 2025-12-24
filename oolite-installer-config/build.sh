#! /usr/bin/bash -x

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

# Stop the installer from rebuilding Oolite when making the installer.
sed -i '281 s/release //' Makefile
sed -i '285 s/release-deployment //' Makefile
sed -i '290 s/release-snapshot //' Makefile

make -j "$(nproc)" -f Makefile pkg-win-"$1"
