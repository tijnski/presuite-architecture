#!/bin/bash
# PreSuite Health Check Script
# Checks the health of all PreSuite services

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Service definitions
declare -A SERVICES=(
  ["PreSuite Hub"]="https://presuite.eu/api/pregpt/status"
  ["PreDrive"]="https://predrive.eu/health"
  ["PreMail"]="https://premail.site/health"
  ["PreOffice"]="https://preoffice.site/health"
)

# Optional: Add server IPs for SSH checks
declare -A SERVERS=(
  ["PreSuite Hub"]="76.13.2.221"
  ["PreDrive"]="76.13.1.110"
  ["PreMail"]="76.13.1.117"
  ["PreOffice"]="76.13.2.220"
)

echo "=========================================="
echo "       PreSuite Health Check"
echo "=========================================="
echo ""

total=0
healthy=0

for service in "${!SERVICES[@]}"; do
  url="${SERVICES[$service]}"
  total=$((total + 1))

  printf "%-15s ... " "$service"

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
done

echo ""
echo "=========================================="
echo "Summary: $healthy/$total services healthy"
echo "=========================================="

# Exit with error if any service is down
if [ "$healthy" -lt "$total" ]; then
  exit 1
fi
