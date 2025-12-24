#! /usr/bin/bash

###############################
#
# Copy the required dlls to the oolite.app folder
#
# Usage: ./copy-dlls-loop.sh [application_name] [MINGW64|CLANG64]
#
# The script expects to be called by oolite-config/build.sh, being run from the root of the oolite-msys2 repository.
# It expects Oolite to have been built.
#
###############################

# Check if the required arguments are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <application_name> <MINGW64|CLANG64>"
    exit 1
fi

# Store the application name provided as argument
app_name=$1
app_location="$(dirname "$app_name")/"

# Get the MSYS2 Environment
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

# Get the list of DLLs for the application using 'ldd' command
dll_list=$(ntldd -R "$app_name")
echo "DLLs used by $app_name:"
echo "$dll_list"

# Check if any DLLs are found
if [ -z "$dll_list" ]; then
    echo "No DLLs found for the application: $app_name"
    exit 1
fi

# Filter the DLLs by those in /mingw64/bin
    filtered_dll_list=$(echo "$dll_list" | grep "\\\\$build_system\\\\bin" | awk '{print $3}' | sort -u)
    if [ -z "$filtered_dll_list" ]; then
        echo "No DLLs found in directory: /$build_system/bin"
        exit 1
    fi
    echo "Filtered DLLs in directory /$build_system/bin used by $app_name:"
    echo "$filtered_dll_list"

# Copy the required dlls to the oolite.app folder using the filtered list
for dll in $filtered_dll_list; do
    echo "Copying $dll"
    cp "$dll" "$app_location"
done

###############################

# Try asking Oolite again what dlls it thinks it needs after copying
echo "Checking dlls after copying"
post_copy_dll_list=$(ntldd -R "$app_name")
echo "$post_copy_dll_list"

###############################
