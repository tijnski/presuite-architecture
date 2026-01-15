#!/bin/bash
# PreSuite Secret Synchronization Script
# Ensures JWT_SECRET is consistent across all servers

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Server definitions
SERVERS=(
  "76.13.2.221:/var/www/presuite/.env"          # PreSuite Hub
  "76.13.1.110:/opt/predrive/.env"              # PreDrive
  "76.13.1.117:/opt/premail/.env"               # PreMail
  "76.13.2.220:/opt/preoffice/presearch/online/.env"  # PreOffice
)

echo "=========================================="
echo "    PreSuite Secret Sync Check"
echo "=========================================="
echo ""

# Array to store secrets
declare -A SECRETS

# Fetch JWT_SECRET from each server
for server_path in "${SERVERS[@]}"; do
  server="${server_path%%:*}"
  path="${server_path#*:}"

  printf "Checking $server ... "

  secret=$(ssh -o ConnectTimeout=5 "root@$server" "grep '^JWT_SECRET=' $path 2>/dev/null | cut -d= -f2" 2>/dev/null || echo "UNREACHABLE")

  if [ "$secret" = "UNREACHABLE" ]; then
    echo -e "${RED}UNREACHABLE${NC}"
    SECRETS["$server"]="UNREACHABLE"
  elif [ -z "$secret" ]; then
    echo -e "${YELLOW}NOT SET${NC}"
    SECRETS["$server"]="NOT_SET"
  else
    # Show first 8 chars only for security
    echo -e "${GREEN}OK${NC} (${secret:0:8}...)"
    SECRETS["$server"]="$secret"
  fi
done

echo ""

# Check if all secrets match
first_secret=""
all_match=true

for server in "${!SECRETS[@]}"; do
  secret="${SECRETS[$server]}"

  if [ "$secret" = "UNREACHABLE" ] || [ "$secret" = "NOT_SET" ]; then
    all_match=false
    continue
  fi

  if [ -z "$first_secret" ]; then
    first_secret="$secret"
  elif [ "$secret" != "$first_secret" ]; then
    all_match=false
  fi
done

echo "=========================================="
if [ "$all_match" = true ] && [ -n "$first_secret" ]; then
  echo -e "${GREEN}All JWT secrets are synchronized${NC}"
else
  echo -e "${RED}JWT secrets are NOT synchronized!${NC}"
  echo ""
  echo "To fix, run on each server:"
  echo "  export JWT_SECRET=\$(openssl rand -hex 32)"
  echo "  # Then update .env files with the same secret"
  exit 1
fi
echo "=========================================="
