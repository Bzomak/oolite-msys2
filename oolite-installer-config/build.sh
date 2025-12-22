#! /usr/bin/bash -x

###############################
#
# Configure and build the Oolite installers
#
# Usage: ./build.sh [release|release-deployment|release-snapshot]
#
# The script expects to be run from the root of the oolite-msys2 repository.
# It expects tools-make to be installed, and for oolite to be downloaded and built.
#
###############################

cd oolite || exit

make -j "$(nproc)" -f Makefile pkg-win-"$1"
