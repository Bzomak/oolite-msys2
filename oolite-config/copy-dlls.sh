#! /usr/bin/bash

###############################
#
# Copy the required dlls to the oolite.app folder
#
# Usage: ./copy-dlls-loop.sh [application_name]
#
# The script expects to be called by oolite-config/build.sh, being run from the root of the oolite-msys2 repository.
# It expects Oolite to have been built.
#
###############################

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

# Check if the required arguments are provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <application_name>"
    exit 1
fi

# Store the application name provided as argument
app_name=$1
app_location="$(dirname "$app_name")/"

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
