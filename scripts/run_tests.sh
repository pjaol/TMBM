#!/bin/bash

# TMBM Test Runner Script
# This script runs the tests for the TMBM project

set -e  # Exit immediately if a command exits with a non-zero status

echo "Starting TMBM tests..."

# Set up colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Create logs directory if it doesn't exist
mkdir -p build-logs

# Get the current date and time for the log file
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="build-logs/test_run_${TIMESTAMP}.log"

echo "Logging test output to ${LOG_FILE}"

# Function to run tests
run_tests() {
    echo -e "${YELLOW}Building and testing CorePackage...${NC}"
    
    # Navigate to the CorePackage directory
    cd CorePackage
    
    # Clean any previous build artifacts
    echo "Cleaning previous build artifacts..."
    swift package clean
    
    # Build the package in debug mode
    echo "Building package..."
    swift build -c debug
    
    # Run the tests with async support
    echo "Running tests..."
    swift test --enable-test-discovery --sanitize=thread
    
    # Return to the original directory
    cd ..
    
    echo -e "${GREEN}Tests completed successfully!${NC}"
}

# Main execution
echo "Environment information:"
echo "Swift version: $(swift --version)"
echo "macOS version: $(sw_vers -productVersion)"
echo ""

# Run the tests and capture output
if run_tests 2>&1 | tee -a "${LOG_FILE}"; then
    echo -e "${GREEN}All tests passed successfully!${NC}"
    exit 0
else
    echo -e "${RED}Tests failed. Check the log file for details: ${LOG_FILE}${NC}"
    exit 1
fi 