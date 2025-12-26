#! /usr/bin/bash

###############################
#
# Configure and build Oolite's JavaScript engine
#
# The script expects to be run from the root of the oolite-msys2 repository.
#
###############################

cd oolite_mozjsnspr_mingw64/js/src || exit
if [ "$1" = "release" ] || [ "$1" = "release-deployment" ] || [ "$1" = "release-snapshot" ]; then
    ./build_js_release.sh
elif [ "$1" = "debug" ]; then
    ./build_js_debug.sh
else
    echo "Usage: $0 [debug|release|release-deployment|release-snapshot]"
    exit 1
fi
