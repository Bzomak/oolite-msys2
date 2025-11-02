#! /usr/bin/bash

###############################
#
# Extract a data string from a file and store it in a GitHub output variable
#
# Usage: Call `bash extract-data-string-from-file.sh [input_path]` from the run step in the workflow file
#
###############################

# Function to handle errors
handle_error() {
    local error_message="$1"
    
    # Always write to GITHUB_OUTPUT
    if [[ -n "$GITHUB_OUTPUT" ]]; then
        echo "error=$error_message" >> "$GITHUB_OUTPUT"
        echo "success=false" >> "$GITHUB_OUTPUT"
    fi
    
    # Only show error annotation in production
    if [[ "${TESTING_MODE}" != "true" ]]; then
        echo "::error::$error_message"
    fi
    
    # Output to stderr for debugging
    echo "$error_message" >&2
    
    return 1
}

# Function to handle success
handle_success() {
    local data="$1"
    
    if [[ -n "$GITHUB_OUTPUT" ]]; then
        {
            echo "data<<EOF"
            echo "$data"
            echo "EOF"
            echo "success=true"
        } >> "$GITHUB_OUTPUT"
    fi
    
    return 0
}

# Main logic
if [ $# -ne 1 ]; then
    handle_error "Path is required"
    exit_code=1
elif [[ -z "$1" || "$1" =~ ^[[:space:]]*$ ]]; then
    handle_error "Path is required"
    exit_code=1
elif [ ! -e "$1" ]; then
    handle_error "Path does not exist"
    exit_code=1
elif [ -d "$1" ]; then
    handle_error "Path is a directory"
    exit_code=1
else
    DATA=$(cat "$1")
    handle_success "$DATA"
    exit_code=0
fi

# Exit with error code only in production mode
#if [[ "${TESTING_MODE}" == "true" ]]; then
#    exit 0
#else
#    exit $exit_code
#fi
