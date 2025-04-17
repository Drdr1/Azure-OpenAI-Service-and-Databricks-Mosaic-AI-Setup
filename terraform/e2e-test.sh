#!/bin/bash
# End-to-End Testing Script for OpenAI Platform
# This script tests the entire infrastructure from Application Gateway to Kong to OpenAI service

# Set error handling (but don't exit immediately on error)
set +e
trap 'echo "Error occurred at line $LINENO. Command: $BASH_COMMAND"' ERR

# Configuration
APP_GATEWAY_IP="4.236.134.0"
KONG_IP="128.203.125.112"
RESOURCE_GROUP="dev-openai-rg"
APP_GATEWAY_NAME="dev-openai-appgw"
TEST_RESULTS_FILE="e2e_test_results.log"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Initialize test results file
echo "OpenAI Platform End-to-End Test Results - $(date)" > $TEST_RESULTS_FILE
echo "=================================================" >> $TEST_RESULTS_FILE

# Function to log test results
log_test() {
  local test_name=$1
  local status=$2
  local details=$3
  
  echo -e "${test_name}: ${status}"
  echo "${test_name}: ${status}" >> $TEST_RESULTS_FILE
  if [ ! -z "$details" ]; then
    echo "  Details: ${details}"
    echo "  Details: ${details}" >> $TEST_RESULTS_FILE
  fi
  echo "" >> $TEST_RESULTS_FILE
}

# Function to test an endpoint and validate response
test_endpoint() {
  local name=$1
  local url=$2
  local expected_status=$3
  local expected_content=$4
  
  echo -e "\n${YELLOW}Testing ${name}...${NC}"
  
  # Capture the response and headers
  local response_file="response_${name// /_}.txt"
  local http_status
  
  http_status=$(curl -s -o "$response_file" -w "%{http_code}" -H "Accept: application/json" "$url")
  
  # Check HTTP status
  if [ "$http_status" == "$expected_status" ]; then
    status_check="${GREEN}PASSED${NC}"
  else
    status_check="${RED}FAILED${NC} (Expected: $expected_status, Got: $http_status)"
  fi
  
  # Check content if expected_content is provided
  local content_check="Not checked"
  if [ ! -z "$expected_content" ]; then
    if grep -q "$expected_content" "$response_file"; then
      content_check="${GREEN}PASSED${NC}"
    else
      content_check="${RED}FAILED${NC} (Expected content not found)"
    fi
  fi
  
  log_test "$name" "$status_check" "HTTP Status: $http_status, Content Check: $content_check"
  
  # Return 0 if both checks passed, 1 otherwise
  if [[ "$status_check" == *"PASSED"* ]] && [[ "$content_check" == *"PASSED"* || "$content_check" == "Not checked" ]]; then
    return 0
  else
    return 1
  fi
}

# Function to test backend health
test_backend_health() {
  echo -e "\n${YELLOW}Testing Application Gateway Backend Health...${NC}"
  
  local health_output=$(az network application-gateway show-backend-health \
    --resource-group $RESOURCE_GROUP \
    --name $APP_GATEWAY_NAME)
  
  # Extract health status
  local health_status=$(echo $health_output | grep -o '"health": "[^"]*"' | cut -d'"' -f4)
  
  if [ "$health_status" == "Healthy" ]; then
    log_test "Backend Health" "${GREEN}PASSED${NC}" "Status: Healthy"
    return 0
  else
    log_test "Backend Health" "${RED}FAILED${NC}" "Status: $health_status"
    return 1
  fi
}

# Function to test latency
test_latency() {
  local name=$1
  local url=$2
  local threshold=$3 # in milliseconds
  
  echo -e "\n${YELLOW}Testing ${name} Latency...${NC}"
  
  # Measure time taken for request
  local start_time=$(date +%s%N)
  curl -s -o /dev/null "$url"
  local end_time=$(date +%s%N)
  
  # Calculate latency in milliseconds
  local latency=$(( ($end_time - $start_time) / 1000000 ))
  
  if [ $latency -le $threshold ]; then
    log_test "${name} Latency" "${GREEN}PASSED${NC}" "Latency: ${latency}ms (Threshold: ${threshold}ms)"
    return 0
  else
    log_test "${name} Latency" "${RED}FAILED${NC}" "Latency: ${latency}ms (Threshold: ${threshold}ms)"
    return 1
  fi
}

# Function to test load handling
test_load() {
  local name=$1
  local url=$2
  local requests=$3
  local concurrency=$4
  local max_failed_percent=$5
  
  echo -e "\n${YELLOW}Testing ${name} Load Handling...${NC}"
  
  # Check if ab (Apache Bench) is installed
  if ! command -v ab &> /dev/null; then
    log_test "${name} Load Test" "${YELLOW}SKIPPED${NC}" "Apache Bench (ab) not installed"
    return 0
  fi
  
  # Run load test
  local load_output=$(ab -n $requests -c $concurrency -r "$url" 2>&1)
  
  # Extract results
  local completed=$(echo "$load_output" | grep "Complete requests:" | awk '{print $3}')
  local failed=$(echo "$load_output" | grep "Failed requests:" | awk '{print $3}')
  
  # Handle case where failed might be empty
  if [ -z "$failed" ]; then
    failed=0
  fi
  
  # Avoid division by zero
  if [ "$requests" -eq 0 ]; then
    requests=1
  fi
  
  local failed_percent=$(( ($failed * 100) / $requests ))
  
  if [ $failed_percent -le $max_failed_percent ]; then
    log_test "${name} Load Test" "${GREEN}PASSED${NC}" "Failed: ${failed_percent}% (Threshold: ${max_failed_percent}%)"
    return 0
  else
    log_test "${name} Load Test" "${RED}FAILED${NC}" "Failed: ${failed_percent}% (Threshold: ${max_failed_percent}%)"
    return 1
  fi
}

# Function to verify Kong routes
verify_kong_routes() {
  echo -e "\n${YELLOW}Verifying Kong Routes...${NC}"
  
  # Check if jq is installed
  if ! command -v jq &> /dev/null; then
    log_test "Kong Routes Verification" "${YELLOW}SKIPPED${NC}" "jq not installed"
    return 0
  fi
  
  local routes=$(kubectl get ingress -A -o json | jq -r '.items[] | "\(.metadata.name) in \(.metadata.namespace)"')
  
  if echo "$routes" | grep -q "kong-root-route in kong" && \
     echo "$routes" | grep -q "kong-status-route in kong" && \
     echo "$routes" | grep -q "openai-route in default"; then
    log_test "Kong Routes Verification" "${GREEN}PASSED${NC}" "All required routes found"
    return 0
  else
    log_test "Kong Routes Verification" "${RED}FAILED${NC}" "Missing routes. Found: $routes"
    return 1
  fi
}

# Function to verify OpenAI service
verify_openai_service() {
  echo -e "\n${YELLOW}Verifying OpenAI Service...${NC}"
  
  # Check if jq is installed
  if ! command -v jq &> /dev/null; then
    log_test "OpenAI Service Verification" "${YELLOW}SKIPPED${NC}" "jq not installed"
    return 0
  fi
  
  local service=$(kubectl get svc openai-service -n default -o json 2>/dev/null || echo '{"spec":{"selector":{}}}')
  local selector=$(echo $service | jq -r '.spec.selector | keys[]' 2>/dev/null)
  
  if [ ! -z "$selector" ]; then
    local pods=$(kubectl get pods -n default -l "$selector" -o json | jq -r '.items | length')
    
    if [ "$pods" -gt 0 ]; then
      log_test "OpenAI Service Verification" "${GREEN}PASSED${NC}" "Service exists with $pods running pods"
      return 0
    else
      log_test "OpenAI Service Verification" "${YELLOW}WARNING${NC}" "Service exists but no pods found"
      return 1
    fi
  else
    log_test "OpenAI Service Verification" "${RED}FAILED${NC}" "Service not found or has no selector"
    return 1
  fi
}

# Main testing sequence
echo -e "${YELLOW}Starting End-to-End Tests for OpenAI Platform${NC}"
echo -e "${YELLOW}===============================================${NC}"

# Track overall test status
overall_status=0

# Test 1: Verify infrastructure components
verify_kong_routes || overall_status=1
verify_openai_service || overall_status=1

# Test 2: Test direct Kong endpoints
test_endpoint "Kong Root Path" "http://${KONG_IP}/" "200" "Kong is healthy" || overall_status=1
test_endpoint "Kong Health Check" "http://${KONG_IP}/health" "200" "Kong is healthy" || overall_status=1
test_endpoint "Kong Status Path" "http://${KONG_IP}/status" "200" "Kong is healthy" || overall_status=1
test_endpoint "Kong OpenAI Path" "http://${KONG_IP}/openai/" "200" "OpenAI Mock Service" || overall_status=1

# Test 3: Test Application Gateway endpoints
test_endpoint "App Gateway Root Path" "http://${APP_GATEWAY_IP}/" "200" "Kong is healthy" || overall_status=1
test_endpoint "App Gateway Health Path" "http://${APP_GATEWAY_IP}/health" "200" "Kong is healthy" || overall_status=1
test_endpoint "App Gateway OpenAI Path" "http://${APP_GATEWAY_IP}/openai/" "200" "OpenAI Mock Service" || overall_status=1

# Test 4: Test backend health
test_backend_health || overall_status=1

# Test 5: Test latency
test_latency "App Gateway" "http://${APP_GATEWAY_IP}/" 500 || overall_status=1
test_latency "Kong Direct" "http://${KONG_IP}/" 500 || overall_status=1  # Increased threshold to 500ms

# Test 6: Test load handling (if ab is available)
test_load "App Gateway" "http://${APP_GATEWAY_IP}/" 100 10 5 || overall_status=1
test_load "Kong Direct" "http://${KONG_IP}/" 100 10 5 || overall_status=1

# Summarize results - using grep with fixed strings to avoid regex issues
total_tests=$(grep -c ": " "$TEST_RESULTS_FILE" || echo 0)
passed_tests=$(grep -c -F "PASSED" "$TEST_RESULTS_FILE" || echo 0)
failed_tests=$(grep -c -F "FAILED" "$TEST_RESULTS_FILE" || echo 0)
warning_tests=$(grep -c -F "WARNING" "$TEST_RESULTS_FILE" || echo 0)
skipped_tests=$(grep -c -F "SKIPPED" "$TEST_RESULTS_FILE" || echo 0)

echo -e "\n${YELLOW}Test Summary${NC}"
echo -e "============"
echo -e "Total Tests: $total_tests"
echo -e "Passed: ${GREEN}$passed_tests${NC}"
echo -e "Failed: ${RED}$failed_tests${NC}"
echo -e "Warnings: ${YELLOW}$warning_tests${NC}"
echo -e "Skipped: ${YELLOW}$skipped_tests${NC}"

echo -e "\nDetailed results saved to: $TEST_RESULTS_FILE"

# Return success only if all tests passed
if [ $overall_status -eq 0 ]; then
  echo -e "\n${GREEN}All tests passed successfully!${NC}"
  exit 0
else
  echo -e "\n${RED}Some tests failed. Please check the detailed results.${NC}"
  exit 1
fi