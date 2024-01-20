#! /usr/bin/bash -eux

###############################

# Download msys2 from https://www.msys2.org/
# Installer from page above links to https://github.com/msys2/msys2-installer/releases/download/2023-07-18/msys2-x86_64-20230718.exe

# Install msys2

# Open msys2 mingw64

# Update msys2 (May need to run twice. Not needed when using msys2/setup-msys2@v2 GitHub Action)
# pacman -Syu

###############################

# Install useful tools for building
pacman -S --noconfirm git

###############################

# Install build dependencies for GNUstep make
. ./deps/tools-make/msys2-deps.env
pacman -S --noconfirm --needed $TOOLS_MAKE_MSYS2_DEPS

# Clone tools-make repo
. ./deps/tools-make/version.env
git clone https://github.com/gnustep/tools-make.git --branch=$TOOLS_MAKE_VERSION

# Make and Install gmake
./deps/tools-make/build.sh
./deps/tools-make/install.sh
. /mingw64/share/GNUstep/Makefiles/GNUstep.sh

###############################

# Install build dependencies for GNUstep libs-base
. ./deps/libs-base/msys2-deps.env
pacman -S --noconfirm --needed $LIBS_BASE_MSYS2_DEPS

# Clone libs-base repo - Using latest - Needs https://github.com/gnustep/libs-base/pull/295
. ./deps/libs-base/version.env
git clone https://github.com/gnustep/libs-base.git 
git checkout $LIBS_BASE_VERSION

# Make and install libs-base
./deps/libs-base/build.sh
./deps/libs-base/install.sh

###############################

# Download Oolite SDL patch
git clone https://github.com/OoliteProject/oolite-windows-dependencies.git Windows-deps --sparse
git sparse-checkout set OOSDLWin32Patch

###############################

# Install build dependencies for SDL
. ./deps/sdl/msys2-deps.env
pacman -S --noconfirm --needed $SDL_MSYS2_DEPS

# Download SDL and extract from tarball
. ./deps/sdl/version.env
wget $SDL_VERSION
tar -xf SDL-1.2.13.tar.gz

./deps/sdl/build.sh
./deps/sdl/install.sh

###############################

# Now let's try to compile Oolite

# Clone Oolite repo and submodules
git clone --recursive https://github.com/OoliteProject/oolite.git

cd oolite

# Add -fobjc-exceptions and -fcommon to OBJC flags in GNUMakefile, line 36
# Since gcc 10 -fno-common is default; add -fcommon to avoid 9425 (yes, 9425!) errors of the form
# C:/msys64/mingw64/bin/../lib/gcc/x86_64-w64-mingw32/13.2.0/../../../../x86_64-w64-mingw32/bin/ld.exe: ./obj.win.spk/oolite.obj/OODebugSupport.m.o:C:\msys64\home\Robert\oolite/src/Core/OOOpenGLExtensionManager.h:280: multiple definition of `glClampColor'; ./obj.win.spk/oolite.obj/OODebugMonitor.m.o:C:\msys64\home\Robert\oolite/src/Core/OOOpenGLExtensionManager.h:280: first defined here
# https://gcc.gnu.org/bugzilla/show_bug.cgi?id=85678

sed -i '36 s/$/ -fobjc-exceptions -fcommon/' GNUMakefile

# Fix inability to find js lib
# Uncomment JS_LIB_DIR
sed -i '25 s/^#//' GNUMakefile
# Add JS_LIB_DIR to ADDITIONAL_OBJC_LIBS
sed -i '33 s/-l$(JS_IMPORT_LIBRARY) /-L$(JS_LIB_DIR) &/' GNUMakefile

# Use tool.make instead of objc.make
sed -i '452 s/objc.make/tool.make/' GNUMakefile
sed -i 's/OBJC_PROGRAM_NAME/TOOL_NAME/' GNUMakefile
sed -i 's/OBJC_PROGRAM_NAME/TOOL_NAME/' GNUmakefile.postamble

# Try to build
make -j $(nproc) -f Makefile release

###############################
###############################
###############################

# Copy these dlls to the oolite.app folder
cp /mingw64/bin/libobjc-4.dll ./oolite.app/
cp /mingw64/bin/gnustep-base-1_29.dll ./oolite.app/
cp /mingw64/bin/libgcc_s_seh-1.dll ./oolite.app/
cp /mingw64/bin/libffi-8.dll ./oolite.app/
cp /mingw64/bin/libgnutls-30.dll ./oolite.app/
cp /mingw64/bin/libwinpthread-1.dll ./oolite.app/
cp /mingw64/bin/libicuin74.dll ./oolite.app/
cp /mingw64/bin/libicuuc74.dll ./oolite.app/
cp /mingw64/bin/libxslt-1.dll ./oolite.app/
cp /mingw64/bin/libbrotlidec.dll ./oolite.app/
cp /mingw64/bin/libbrotlienc.dll ./oolite.app/
cp /mingw64/bin/libgmp-10.dll ./oolite.app/
cp /mingw64/bin/libhogweed-6.dll ./oolite.app/
cp /mingw64/bin/libidn2-0.dll ./oolite.app/
cp /mingw64/bin/libintl-8.dll ./oolite.app/
cp /mingw64/bin/libnettle-8.dll ./oolite.app/
cp /mingw64/bin/libtasn1-6.dll ./oolite.app/
cp /mingw64/bin/libp11-kit-0.dll ./oolite.app/
cp /mingw64/bin/libunistring-5.dll ./oolite.app/
cp /mingw64/bin/libzstd.dll ./oolite.app/
cp /mingw64/bin/libstdc++-6.dll ./oolite.app/
cp /mingw64/bin/libicudt74.dll ./oolite.app/
cp /mingw64/bin/libbrotlicommon.dll ./oolite.app/
cp /mingw64/bin/liblzma-5.dll ./oolite.app/

# Copy these dlls to the oolite.app folder, overwriting the ones that are already there
cp /mingw64/bin/SDL.dll ./oolite.app/
cp /mingw64/bin/libxml2-2.dll ./oolite.app/
cp /mingw64/bin/libiconv-2.dll ./oolite.app/
cp /mingw64/bin/zlib1.dll  ./oolite.app/
