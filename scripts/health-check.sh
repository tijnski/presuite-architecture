#!/bin/bash
# PreSuite Health Check Script
# Checks the health of all PreSuite services

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=========================================="
echo "       PreSuite Health Check"
echo "=========================================="
echo ""

total=0
healthy=0

check_service() {
  local name="$1"
  local url="$2"
  total=$((total + 1))

  printf "%-15s ... " "$name"

  # Perform health check
  http_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 --max-time 10 "$url" 2>/dev/null || echo "000")

  if [ "$http_code" = "200" ]; then
    echo -e "${GREEN}OK${NC} (HTTP $http_code)"
    healthy=$((healthy + 1))
  elif [ "$http_code" = "000" ]; then
    echo -e "${RED}UNREACHABLE${NC}"
  else
    echo -e "${YELLOW}DEGRADED${NC} (HTTP $http_code)"
  fi
}

# Check all services
check_service "PreSuite Hub" "https://presuite.eu/api/auth/health"
check_service "PreSuite GPT" "https://presuite.eu/api/pregpt/status"
check_service "PreDrive" "https://predrive.eu/health"
check_service "PreMail" "https://premail.site/health"
check_service "PreOffice" "https://preoffice.site/health"

echo ""
echo "=========================================="
echo "Summary: $healthy/$total services healthy"
echo "=========================================="

# Exit with error if any service is down
if [ "$healthy" -lt "$total" ]; then
  exit 1
fi
