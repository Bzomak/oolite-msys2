#!/usr/bin/bash

###############################
#
# Take a list of outcomes and names of tests and generate Markdown for "$GITHUB_STEP_SUMMARY"
# Overall summary first, then detailed breakdown by job type
# Expects test result files in "test-results/" named "*.json" with fields:
#   - name: Name of the test
#   - result: "true" or "false" for pass/fail
#   - job_type: Type of job (e.g., "extract-data-string-from-file
#
###############################

# Overall counters
total_tests=0
total_passed=0
total_failed=0

# Associative arrays for grouping by job_type
declare -A job_totals
declare -A job_passed
declare -A job_failed

# Create temporary files for building content
temp_summary=$(mktemp)

# Process all result files once
for result_file in test-results/*.json; do
    if [[ -f "$result_file" ]]; then
        job_type=$(jq -r '.job_type' "$result_file")
        name=$(jq -r '.name' "$result_file")
        result=$(jq -r '.result' "$result_file")
        
        # Initialize counters for this job type if needed
        if [[ -z "${job_totals[$job_type]}" ]]; then
            job_totals[$job_type]=0
            job_passed[$job_type]=0
            job_failed[$job_type]=0
            
            # Create temp file for this job type
            temp_job_file=$(mktemp)
            echo "$temp_job_file" > "/tmp/job_${job_type}.tmp"
            
            # Write job header
            display_name=$(echo "$job_type" | tr '-' ' ' | sed 's/\b\w/\U&/g')
            {
                echo "### $display_name Tests"
                echo ""
                echo "| Test | Result |"
                echo "|------|--------|"
            } > "$temp_job_file"
        fi
        
        # Get the temp file for this job type
        temp_job_file=$(cat "/tmp/job_${job_type}.tmp")
        
        # Count totals
        job_totals[$job_type]=$((job_totals[$job_type] + 1))
        total_tests=$((total_tests + 1))
        
        # Count pass/fail and write to job temp file
        if [[ "$result" == "true" ]]; then
            job_passed[$job_type]=$((job_passed[$job_type] + 1))
            total_passed=$((total_passed + 1))
            echo "| $name | ✅ PASS |" >> "$temp_job_file"
        else
            job_failed[$job_type]=$((job_failed[$job_type] + 1))
            total_failed=$((total_failed + 1))
            echo "| $name | ❌ FAIL |" >> "$temp_job_file"
        fi
    fi
done

# Build overall summary in temp file
{
    echo "## Overall Test Results"
    echo ""
    
    if [[ $total_failed -eq 0 ]]; then
        echo "### All Tests Passed! ✅"
    else
        echo "### Some Tests Failed ❌"
    fi
    
    echo ""
    echo "**Total Results:** $total_passed/$total_tests tests passed"
    echo ""
    
    # Job type breakdown in summary
    if [[ ${#job_totals[@]} -gt 1 ]]; then
        echo "### By Job Type:"
        for job_type in "${!job_totals[@]}"; do
            display_name=$(echo "$job_type" | tr '-' ' ' | sed 's/\b\w/\U&/g')
            if [[ ${job_failed[$job_type]} -eq 0 ]]; then
                status_icon="✅"
                status_text="ALL PASSED"
            else
                status_icon="❌"
                status_text="${job_failed[$job_type]} FAILED"
            fi
            echo "- **$display_name:** ${job_passed[$job_type]}/${job_totals[$job_type]} $status_icon $status_text"
        done
        echo ""
    fi
    
    echo "---"
    echo ""
    echo "## Detailed Test Results"
    echo ""
} > "$temp_summary"

# Combine all temp files and output to GitHub
{
    cat "$temp_summary"
    
    # Add each job's detailed results
    for job_type in "${!job_totals[@]}"; do
        temp_job_file=$(cat "/tmp/job_${job_type}.tmp")
        
        # Add job summary footer
        display_name=$(echo "$job_type" | tr '-' ' ' | sed 's/\b\w/\U&/g')
        {
            echo ""
            echo "**$display_name Summary:** ${job_passed[$job_type]}/${job_totals[$job_type]} tests passed"
            echo ""
        } >> "$temp_job_file"
        
        cat "$temp_job_file"
    done
} >> "$GITHUB_STEP_SUMMARY"

# Clean up all temp files
rm -f "$temp_summary"
for job_type in "${!job_totals[@]}"; do
    temp_job_file=$(cat "/tmp/job_${job_type}.tmp" 2>/dev/null)
    rm -f "$temp_job_file" "/tmp/job_${job_type}.tmp"
done