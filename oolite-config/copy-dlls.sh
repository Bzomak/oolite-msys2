#! /usr/bin/bash -x

###############################

# Copy the required dlls to the oolite.app folder

###############################

# Try asking Oolite what dlls it thinks it needs
echo "Checking dlls before copying"
ldd ./oolite/oolite.app/oolite.exe


cp /mingw64/bin/libobjc-4.dll ./oolite/oolite.app/
cp /mingw64/bin/gnustep-base-1_29.dll ./oolite/oolite.app/
cp /mingw64/bin/libopenal-1.dll ./oolite/oolite.app/
cp /mingw64/bin/libpng16-16.dll ./oolite/oolite.app/
cp /mingw64/bin/SDL.dll ./oolite/oolite.app/
cp /mingw64/bin/libvorbisfile-3.dll ./oolite/oolite.app/
cp /mingw64/bin/libgcc_s_seh-1.dll ./oolite/oolite.app/
cp /mingw64/bin/libwinpthread-1.dll ./oolite/oolite.app/
CP /mingw64/bin/libstdc++-6.dll ./oolite/oolite.app/
cp /mingw64/bin/libffi-8.dll ./oolite/oolite.app/
cp /mingw64/bin/libicuin74.dll ./oolite/oolite.app/
cp /mingw64/bin/libicuuc74.dll ./oolite/oolite.app/
cp /mingw64/bin/libiconv-2.dll ./oolite/oolite.app/
cp /mingw64/bin/libxml2-2.dll ./oolite/oolite.app/

###############################

# Copy the js lib from the oolite-windows-dependencies repo to the oolite.app folder
# Once we can build it ourselves it can be copied with the other dlls
cp ./oolite/deps/Windows-deps/x86_64/DLLs/js32ECMAv5.dll ./oolite/oolite.app/

###############################

# Try asking Oolite what dlls it thinks it needs
echo "Checking dlls after copying"
ldd ./oolite/oolite.app/oolite.exe
