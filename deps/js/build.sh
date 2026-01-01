#! /usr/bin/bash

###############################
#
# Configure and build Oolite's JavaScript engine
#
# The script expects to be run from the root of the oolite-msys2 repository.
#
###############################

cd oolite_mozjsnspr_mingw64/js/src || exit

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

if [ "$build_system" = "clang64" ]; then
mkdir -p toolchain
cat > toolchain/g++ <<'EOF'
#!/usr/bin/env sh
exec clang++ "$@"
EOF

chmod +x toolchain/g++
export PATH="$PWD/toolchain:$PATH"
which g++
export CFLAGS="-Wno-c++11-narrowing -Wno-register"
export CXXFLAGS="-Wno-c++11-narrowing -Wno-register"
fi
#sed -i 's/g++/$(CXX)/' Makefile.ref

if [ "$1" = "release" ] || [ "$1" = "release-deployment" ] || [ "$1" = "release-snapshot" ]; then
    ./build_js_release.sh
elif [ "$1" = "debug" ]; then
    ./build_js_debug.sh
else
    echo "Usage: $0 [debug|release|release-deployment|release-snapshot]"
    exit 1
fi
