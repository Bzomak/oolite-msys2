#! /usr/bin/bash -x

###############################
#
# Configure and build the Oolite installers
#
# Usage: ./build.sh [release|release-deployment|release-snapshot] [MINGW64|CLANG64]
#
# The script expects to be run from the root of the oolite-msys2 repository.
# It expects tools-make to be installed, and for oolite to be downloaded and built.
#
###############################

cd oolite || exit

msystem=$2
build_system=""
if [ "$msystem" = "MINGW64" ]; then
    build_system="mingw64"
elif [ "$msystem" = "CLANG64" ]; then
    build_system="clang64"
else
    echo "Invalid or missing MSYSTEM argument. Use MINGW64 or CLANG64."
    exit 1
fi

# shellcheck source=/dev/null
. /$build_system/share/GNUstep/Makefiles/GNUstep.sh
make -j "$(nproc)" -f Makefile pkg-win-"$1"
