#!/usr/bin/bash
# filepath: c:\Users\Robert\Documents\GitHub\oolite-msys2\.github\actions\gen-test-summary-md.sh

###############################
#
# Take a list of outcomes and names of tests and generate Markdown for "$GITHUB_STEP_SUMMARY"
#
# Usage: Call `bash gen-test-summary-md.sh` from the run step in the workflow file
#
###############################

total_tests=0
passed_tests=0
failed_tests=0

# Create a temporary file for building the test table
temp_table=$(mktemp)

{
    echo "### Test Summary"
    echo "| Test | Result |"
    echo "|------|---------|"
} > "$temp_table"

for result_file in test-results/*.json; do
    if [[ -f "$result_file" ]]; then
        name=$(jq -r '.name' "$result_file")
        result=$(jq -r '.result' "$result_file")
        total_tests=$((total_tests + 1))
        if [[ "$result" == "true" ]]; then
            echo "| $name | ✅ PASS |" >> "$temp_table"
            passed_tests=$((passed_tests + 1))
        else
            echo "| $name | ❌ FAIL |" >> "$temp_table"
            failed_tests=$((failed_tests + 1))
        fi
    fi
done

{
    echo ""
    echo "**Summary:** $passed_tests/$total_tests tests passed"
} >> "$temp_table"

# Generate the final summary markdown
{
    echo "## Test Results"
    echo ""
    echo "### Passed ✔️: $passed_tests | Failed ❌: $failed_tests"
    echo ""
    echo "#### Tests:"
    cat "$temp_table"
} >> "$GITHUB_STEP_SUMMARY"

# Clean up
rm -f "$temp_table"
