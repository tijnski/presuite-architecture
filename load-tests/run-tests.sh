#!/bin/bash
# PreSuite Load Test Runner
# Runs k6 load tests against PreSuite services

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/results"
SCENARIO="${SCENARIO:-smoke}"

# Ensure results directory exists
mkdir -p "$RESULTS_DIR"

# Check for k6
if ! command -v k6 &> /dev/null; then
    echo -e "${RED}Error: k6 is not installed${NC}"
    echo "Install with: brew install k6 (macOS) or see https://k6.io/docs/getting-started/installation/"
    exit 1
fi

# Print header
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  PreSuite Load Tests - $(date '+%Y-%m-%d %H:%M')${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "Scenario: ${YELLOW}$SCENARIO${NC}"
echo ""

# Function to run a test
run_test() {
    local test_name=$1
    local test_file=$2

    echo -e "${YELLOW}Running: $test_name${NC}"

    k6 run \
        -e SCENARIO="$SCENARIO" \
        -e TEST_EMAIL="${TEST_EMAIL:-}" \
        -e TEST_PASSWORD="${TEST_PASSWORD:-}" \
        -e PRESUITE_URL="${PRESUITE_URL:-https://presuite.eu}" \
        -e PREDRIVE_URL="${PREDRIVE_URL:-https://predrive.eu}" \
        -e PREMAIL_URL="${PREMAIL_URL:-https://premail.site}" \
        -e PREOFFICE_URL="${PREOFFICE_URL:-https://preoffice.site}" \
        "$SCRIPT_DIR/scenarios/$test_file"

    echo ""
}

# Parse command line arguments
TEST_TO_RUN="${1:-all}"

case "$TEST_TO_RUN" in
    "auth")
        run_test "PreSuite Authentication" "presuite-auth.js"
        ;;
    "predrive")
        run_test "PreDrive Files" "predrive-files.js"
        ;;
    "premail")
        run_test "PreMail Inbox" "premail-inbox.js"
        ;;
    "all-services")
        run_test "All Services" "all-services.js"
        ;;
    "all"|"")
        echo -e "${GREEN}Running all load tests...${NC}"
        echo ""
        run_test "PreSuite Authentication" "presuite-auth.js"
        run_test "PreDrive Files" "predrive-files.js"
        run_test "PreMail Inbox" "premail-inbox.js"
        run_test "All Services" "all-services.js"
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 [test] [options]"
        echo ""
        echo "Tests:"
        echo "  auth         Run PreSuite authentication tests"
        echo "  predrive     Run PreDrive file operations tests"
        echo "  premail      Run PreMail inbox tests"
        echo "  all-services Run combined all-services test"
        echo "  all          Run all tests (default)"
        echo ""
        echo "Environment Variables:"
        echo "  SCENARIO       Test scenario: smoke, load, stress, spike (default: smoke)"
        echo "  TEST_EMAIL     Test user email for authenticated tests"
        echo "  TEST_PASSWORD  Test user password"
        echo "  PRESUITE_URL   PreSuite Hub URL (default: https://presuite.eu)"
        echo "  PREDRIVE_URL   PreDrive URL (default: https://predrive.eu)"
        echo "  PREMAIL_URL    PreMail URL (default: https://premail.site)"
        echo "  PREOFFICE_URL  PreOffice URL (default: https://preoffice.site)"
        echo ""
        echo "Examples:"
        echo "  $0 auth                                    # Smoke test auth"
        echo "  SCENARIO=load $0 all                       # Load test all services"
        echo "  SCENARIO=stress TEST_EMAIL=x TEST_PASSWORD=y $0 predrive  # Stress test PreDrive"
        exit 0
        ;;
    *)
        echo -e "${RED}Unknown test: $TEST_TO_RUN${NC}"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Load tests complete!${NC}"
echo -e "${GREEN}  Results saved to: $RESULTS_DIR${NC}"
echo -e "${GREEN}============================================${NC}"
