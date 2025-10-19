#! /usr/bin/bash -x

###############################
#
# Configure and build SDL
#
# The script expects to be run from the root of the oolite-msys2 repository.
# It expects SDL to be downloaded.
#
###############################

# Apply patch from Oolite
patch -s -d SDL-1.2.13 -p1 < ./deps/sdl/OOSDLdll_x64.patch
cd SDL-1.2.13 || exit
./autogen.sh
./configure
# Add flags back that configure seems to remove
sed -i '/^EXTRA_LDFLAGS/ s/$/ -ldxerr8 -ldinput8 -lole32/' Makefile
sed -i '/^EXTRA_LDFLAGS/ s/$/ -Wno-error=implicit-function-declaration -Wno-error=incompatible-pointer-types/' Makefile
make -j "$(nproc)"
