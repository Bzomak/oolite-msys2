#! /usr/bin/bash

###############################
#
# Validate tests for extract-data-string-from-file action
#
###############################

test_name="$1"
expected_outcome="$2"  # "success" or "failure"
expected_data="$3"
expected_error="$4"
actual_success="$5"
actual_data="$6"
actual_error="$7"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Initialize test result variables
test_passed=false

echo -e "\n${YELLOW}Validating: $test_name${NC}"

if [[ "$expected_outcome" == "success" ]]; then
    # For success tests, check success=true and correct data
    if [[ "$actual_success" == "true" && "$actual_data" == "$expected_data" ]]; then
        echo -e "${GREEN}✅ PASS: Got expected data '$expected_data'${NC}"
        test_passed=true
    else
        echo -e "${RED}❌ FAIL: Expected success=true with data '$expected_data', got success='$actual_success' with data '$actual_data'${NC}"
        test_passed=false
    fi
else
    # For failure tests, check success=false and correct error
    if [[ "$actual_success" == "false" && "$actual_error" == *"$expected_error"* ]]; then
        echo -e "${GREEN}✅ PASS: Got expected error containing '$expected_error'${NC}"
        test_passed=true
    else
        echo -e "${RED}❌ FAIL: Expected success=false with error containing '$expected_error', got success='$actual_success' with error '$actual_error'${NC}"
        test_passed=false
    fi
fi

# Output result to GITHUB_OUTPUT
if [[ -n "$GITHUB_OUTPUT" ]]; then
    echo "result=$test_passed" >> "$GITHUB_OUTPUT"
fi
