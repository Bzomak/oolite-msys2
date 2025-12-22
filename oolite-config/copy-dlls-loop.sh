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

# Initialize variables for loop control
iteration=1
prev_dlls=""
max_iterations=10  # Safety limit to prevent infinite loops

echo "Starting iterative DLL copy process for $app_name"
echo "Application location: $app_location"

echo ""
objdump_list=$(objdump -p "$app_name")
echo "DLLs according to objdump:"
echo "$objdump_list"
echo ""
ntldd_list=$(ntldd -R "$app_name")
echo "DLLs according to ntldd:"
echo "$ntldd_list"
echo ""
dll_list=$(ldd "$app_name")
echo "DLLs according to ldd:"
echo "$dll_list"
echo ""

while [ $iteration -le $max_iterations ]; do
    echo ""
    echo "=== Iteration $iteration ==="
    
    # Get the list of DLLs for the application using 'ldd' command
    dll_list=$(ldd "$app_name")
    echo "Checking DLLs for $app_name..."
    
    # Filter the DLLs by those in /$build_system/bin
    filtered_dll_list=$(echo "$dll_list" | grep "/$build_system/bin" | awk '{print $3}' | sort | uniq)
    
    if [ -z "$filtered_dll_list" ]; then
        echo "No DLLs found in directory: /$build_system/bin"
        break
    fi
    
    echo "DLLs in /$build_system/bin required by $app_name:"
    echo "$filtered_dll_list"
    
    # Check if this is the same as the previous iteration
    current_dlls="$filtered_dll_list"
    if [ "$current_dlls" = "$prev_dlls" ]; then
        echo "No new DLLs found. Copy process complete."
        break
    fi
    
    # Copy only new DLLs (those not already present in the destination)
    new_dlls_copied=0
    for dll in $filtered_dll_list; do
        dll_basename=$(basename "$dll")
        if [ ! -f "$app_location$dll_basename" ]; then
            echo "Copying new DLL: $dll"
            cp "$dll" "$app_location"
            new_dlls_copied=$((new_dlls_copied + 1))
        fi
    done
    
    if [ $new_dlls_copied -eq 0 ]; then
        echo "All required DLLs are already present. Process complete."
        break
    else
        echo "Copied $new_dlls_copied new DLL(s) in this iteration."
    fi
    
    # Store current state for next comparison
    prev_dlls="$current_dlls"
    iteration=$((iteration + 1))
done

# Check if we hit the safety limit
if [ $iteration -gt $max_iterations ]; then
    echo "WARNING: Reached maximum iterations ($max_iterations). There might be circular dependencies or other issues."
fi

###############################

# Final check - show all DLLs after copying is complete
echo ""
echo "=== Final DLL check ==="
echo "Checking final DLL dependencies for $app_name:"
final_dll_list=$(ldd "$app_name")
echo "$final_dll_list"

# Summary
echo ""
echo "=== Copy Summary ==="
total_iterations=$((iteration - 1))
echo "Completed in $total_iterations iteration(s)"
echo "DLLs now present in $app_location:"
ls -1 "$app_location"*.dll 2>/dev/null || echo "No .dll files found in destination"

###############################
