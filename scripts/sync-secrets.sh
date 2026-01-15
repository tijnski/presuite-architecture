#!/bin/bash
# PreSuite Secret Synchronization Script
# Ensures JWT_SECRET is consistent across all servers

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "    PreSuite Secret Sync Check"
echo "=========================================="
echo ""

# Store secrets for comparison
secrets=""
all_ok=true

check_secret() {
  local name="$1"
  local server="$2"
  local path="$3"

  printf "%-15s ... " "$name"

  secret=$(ssh -o ConnectTimeout=5 "root@$server" "grep '^JWT_SECRET=' $path 2>/dev/null | cut -d= -f2" 2>/dev/null || echo "UNREACHABLE")

  if [ "$secret" = "UNREACHABLE" ]; then
    echo -e "${RED}UNREACHABLE${NC}"
    all_ok=false
  elif [ -z "$secret" ]; then
    echo -e "${YELLOW}NOT SET${NC}"
    all_ok=false
  else
    # Show first 8 chars only for security
    echo -e "${GREEN}OK${NC} (${secret:0:8}...)"
    secrets="$secrets$secret:"
  fi
}

# Check all servers
check_secret "PreSuite Hub" "76.13.2.221" "/var/www/presuite-api/.env"
check_secret "PreDrive" "76.13.1.110" "/opt/predrive/.env"
check_secret "PreMail" "76.13.1.117" "/opt/premail/.env"
check_secret "PreOffice" "76.13.2.220" "/opt/preoffice/presearch/online/.env"

echo ""

# Check if all secrets match
unique_secrets=$(echo "$secrets" | tr ':' '\n' | sort -u | wc -l)

echo "=========================================="
if [ "$all_ok" = true ] && [ "$unique_secrets" -eq 1 ]; then
  echo -e "${GREEN}All JWT secrets are synchronized${NC}"
else
  echo -e "${RED}JWT secrets are NOT synchronized!${NC}"
  echo ""
  echo "To fix, ensure all .env files have the same JWT_SECRET"
  exit 1
fi
echo "=========================================="
