#! /usr/bin/bash

###############################
#
# Take a list of outcomes and names of tests and generate Markdown for "$GITHUB_STEP_SUMMARY"
#
# Usage: Call `bash gen-test-summary-md.sh [input_path]` from the run step in the workflow file
#
###############################

test_summary=""
total_tests=0
passed_tests=0
failed_tests=0

{
    echo "### Test Summary"
    echo "| Test | Result |"
    echo "|------|---------|"
} >> "$test_summary"

for result_file in test-results/*.json; do
if [[ -f "$result_file" ]]; then
    name=$(jq -r '.name' "$result_file")
    result=$(jq -r '.result' "$result_file")
    
    total_tests=$((total_tests + 1))
    
    if [[ "$result" == "true" ]]; then
    echo "| $name | ✅ PASS |" >> "$test_summary"
    passed_tests=$((passed_tests + 1))
    else
    echo "| $name | ❌ FAIL |" >> "$test_summary"
    failed_tests=$((failed_tests + 1))
    fi
fi
done

echo "" >> "$test_summary"
echo "**Summary:** $passed_tests/$total_tests tests passed" >> "$test_summary"


# Generate the summary markdown
{
    echo "## Test Results"
    echo ""
    echo "### Passed ✔️: $passed_tests | Failed ❌: $failed_tests"
    echo ""
    echo "#### Tests:"
    echo "$test_summary"
} >> "$GITHUB_STEP_SUMMARY"
