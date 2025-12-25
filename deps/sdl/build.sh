#! /usr/bin/bash

###############################
#
# Configure and build SDL
#
# The script expects to be run from the root of the oolite-msys2 repository.
# It expects SDL to be downloaded.
#
###############################

# Guard against nproc failing
num_jobs=$(nproc 2>/dev/null)
if [ -z "$num_jobs" ]; then
    echo "Warning: Could not determine number of processors, using 1 job"
    num_jobs=1
fi

# Apply patch from Oolite
patch -s -d SDL-1.2.13 -p1 < ./deps/sdl/OOSDLdll_x64.patch
cd SDL-1.2.13 || exit
./autogen.sh
./configure --disable-assembly
# Add flags back that configure seems to remove
sed -i '/^EXTRA_LDFLAGS/ s/$/ -ldxerr8 -ldinput8 -lole32/' Makefile
sed -i '/^CFLAGS/ s/$/ -Wno-error=implicit-function-declaration -Wno-error=incompatible-pointer-types/' Makefile
make -j"$num_jobs"
