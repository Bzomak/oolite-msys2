#! /usr/bin/bash

###############################
#
# Configure and build Oolite
#
# Usage: ./build.sh [debug|release|release-deployment|release-snapshot] [MINGW64|CLANG64]
#
# The script expects to be run from the root of the oolite-msys2 repository.
# It expects tools-make, libs-base, and SDL to be downloaded and installed.
# It expects Oolite to be downloaded.
#
###############################

cd oolite || exit

# Check if MINGW_PREFIX is set
if [ -z "$MINGW_PREFIX" ]; then
    echo "Error: MINGW_PREFIX is not set."
    echo "This script must be run from an MSYS2 MINGW64 or CLANG64 environment."
    exit 1
fi

# Extract build system from MINGW_PREFIX (e.g., /mingw64 -> mingw64)
build_system=$(basename "$MINGW_PREFIX")

# Validate build system
if [ "$build_system" != "mingw64" ] && [ "$build_system" != "clang64" ]; then
    echo "Error: Unsupported MINGW_PREFIX: $MINGW_PREFIX"
    echo "Expected /mingw64 or /clang64"
    exit 1
fi

echo "Using build system: $build_system (from MINGW_PREFIX: $MINGW_PREFIX)"

# Guard against nproc failing
num_jobs=$(nproc 2>/dev/null)
if [ -z "$num_jobs" ]; then
    echo "Warning: Could not determine number of processors, using 1 job"
    num_jobs=1
fi

# Add -fobjc-exceptions to OBJC flags in GNUMakefile when compiling with GCC on /mingw64
# Fixes "error: '-fobjc-exceptions' is required to enable Objective-C exception syntax"
if [ "$build_system" = "mingw64" ]; then
    sed -i '51 s/$/ -fobjc-exceptions/' GNUMakefile
fi

# Use tool.make instead of objc.make
# objc.make was deprecated in favour of tool.make in version 2.6.0 of GNUstep Make.
sed -i 's/objc.make/tool.make/' GNUMakefile
sed -i 's/OBJC_PROGRAM_NAME/TOOL_NAME/' GNUMakefile
sed -i 's/OBJC_PROGRAM_NAME/TOOL_NAME/' GNUmakefile.postamble 

###############################

# Fix inability to find js lib
# Uncomment JS_LIB_DIR
sed -i '30 s/^#//' GNUMakefile
# Add JS_LIB_DIR to ADDITIONAL_OBJC_LIBS
# shellcheck disable=SC2016
sed -i '48 s/-l$(JS_IMPORT_LIBRARY) /-L$(JS_LIB_DIR) &/' GNUMakefile

# shellcheck disable=SC2016
# Keeping -I$(JS_INC_DIR)
sed -i '47 s/$/ -I$(JS_INC_DIR) /' GNUMakefile

# Don't copy js dll here yet until we can build it ourselves.
# sed needs to comment out lines 90 to 107 in Gnumakefile.postamble
# Need to copy the correct dlls to the oolite.app folder
# Some dlls missing, so using my own script to copy them (seems to be the same, but will be easier to debug)
# dlls not copied for debug build in Oolite's Makefile, so need to handle that here too
sed -i '90,107 s/^/#/' Gnumakefile.postamble

###############################

# Try to build
# shellcheck source=/dev/null
. "/$build_system/share/GNUstep/Makefiles/GNUstep.sh"
make -j"$num_jobs" -f Makefile "$1"

cd ..
# Temporary fix: copy nspr4.dll to oolite.app folder until we build the js lib ourselves.
# Then we can use the MSYS2 provided nspr lib instead.
# A debug build needs the debug javascript dll rather than the regular version.
# The debug executable is oolite.dbg.exe, not oolite.exe
cp ./oolite/deps/Windows-deps/x86_64/DLLs/nspr4.dll ./oolite/oolite.app/
if [ "$1" = "release" ] || [ "$1" = "release-deployment" ] || [ "$1" = "release-snapshot" ]; then
    # Copy the js lib from the oolite-windows-dependencies repo to the oolite.app folder
    # Once we can build it ourselves it can be copied with the other dlls
    cp ./oolite/deps/Windows-deps/x86_64/DLLs/js32ECMAv5.dll ./oolite/oolite.app/
    ./oolite-config/copy-dlls.sh ./oolite/oolite.app/oolite.exe
elif [ "$1" = "debug" ]; then
    # Copy the js lib from the oolite-windows-dependencies repo to the oolite.app folder
    # Once we can build it ourselves it can be copied with the other dlls
    cp ./oolite/deps/Windows-deps/x86_64/DLLs/js32ECMAv5dbg.dll ./oolite/oolite.app/
    ./oolite-config/copy-dlls.sh ./oolite/oolite.app/oolite.dbg.exe
fi
