#!/bin/bash
# PreSuite Full Deployment Script
# Deploys all services to their respective servers

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
GITHUB_USER="tijnski"
REPOS_BASE="$HOME/presuite"

# Server definitions
declare -A SERVERS=(
  ["presuite"]="76.13.2.221"
  ["predrive"]="76.13.1.110"
  ["premail"]="76.13.1.117"
  ["preoffice"]="76.13.2.220"
)

declare -A PATHS=(
  ["presuite"]="/var/www/presuite"
  ["predrive"]="/opt/predrive"
  ["premail"]="/opt/premail"
  ["preoffice"]="/opt/preoffice/presearch/online"
)

# Parse arguments
SERVICE=$1

if [ -z "$SERVICE" ]; then
  echo "Usage: $0 <service|all>"
  echo ""
  echo "Services: presuite, predrive, premail, preoffice, all"
  exit 1
fi

deploy_service() {
  local service=$1
  local server="${SERVERS[$service]}"
  local path="${PATHS[$service]}"

  echo -e "${BLUE}========================================${NC}"
  echo -e "${BLUE}Deploying $service to $server${NC}"
  echo -e "${BLUE}========================================${NC}"

  case $service in
    presuite)
      echo "Building PreSuite..."
      cd "$REPOS_BASE/presuite" || exit 1
      npm run build

      echo "Uploading to server..."
      scp -r dist/* "root@$server:/var/www/presuite/"

      echo "Restarting PM2..."
      ssh "root@$server" "pm2 restart presuite-api"
      ;;

    predrive)
      echo "Building PreDrive..."
      cd "$REPOS_BASE/predrive" || exit 1
      pnpm build

      echo "Syncing to server..."
      rsync -avz --delete \
        --exclude='.env' \
        --exclude='node_modules' \
        --exclude='.git' \
        . "root@$server:$path/"

      echo "Rebuilding containers..."
      ssh "root@$server" "cd $path && docker compose -f deploy/docker-compose.prod.yml up -d --build"
      ;;

    premail)
      echo "Building PreMail..."
      cd "$REPOS_BASE/premail" || exit 1
      pnpm build

      echo "Syncing to server..."
      rsync -avz --delete \
        --exclude='.env' \
        --exclude='node_modules' \
        --exclude='.git' \
        . "root@$server:$path/"

      echo "Restarting PM2..."
      ssh "root@$server" "cd $path && pm2 restart premail-api premail-web --update-env"
      ;;

    preoffice)
      echo "Building PreOffice..."
      cd "$REPOS_BASE/preoffice/presearch/online" || exit 1

      echo "Syncing to server..."
      rsync -avz --delete \
        --exclude='.env' \
        --exclude='node_modules' \
        --exclude='.git' \
        . "root@$server:$path/"

      echo "Rebuilding containers..."
      ssh "root@$server" "cd $path && docker compose down && docker compose up -d --build"
      ;;

    *)
      echo -e "${RED}Unknown service: $service${NC}"
      return 1
      ;;
  esac

  echo -e "${GREEN}$service deployed successfully${NC}"
  echo ""
}

# Deploy services
if [ "$SERVICE" = "all" ]; then
  for svc in presuite predrive premail preoffice; do
    deploy_service "$svc"
  done
else
  deploy_service "$SERVICE"
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment complete!${NC}"
echo -e "${GREEN}========================================${NC}"

# Run health check
echo ""
echo "Running health check..."
./scripts/health-check.sh
