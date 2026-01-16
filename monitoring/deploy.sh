#!/bin/bash
#
# Deploy PreSuite Monitoring Infrastructure
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Server configurations
PRESUITE_SERVER="root@76.13.2.221"
PREDRIVE_SERVER="root@76.13.1.110"
PREMAIL_SERVER="root@76.13.1.117"
PREOFFICE_SERVER="root@76.13.2.220"

# Remote paths
MONITORING_PATH="/opt/presuite/monitoring"
BACKUP_PATH="/opt/presuite-backups"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[DEPLOY]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

deploy_to_server() {
    local server="$1"
    local name="$2"

    log "Deploying to ${name} (${server})..."

    # Create directories
    ssh "$server" "mkdir -p ${MONITORING_PATH} ${BACKUP_PATH}/{databases,files,logs}"

    # Copy monitoring files
    rsync -avz --exclude 'node_modules' --exclude 'dist' \
        "${SCRIPT_DIR}/" "${server}:${MONITORING_PATH}/"

    # Make scripts executable
    ssh "$server" "chmod +x ${MONITORING_PATH}/backups/*.sh"

    log "Deployed to ${name}"
}

setup_cron() {
    local server="$1"
    local name="$2"

    log "Setting up cron on ${name}..."

    # Add backup cron job (daily at 2 AM)
    ssh "$server" "crontab -l 2>/dev/null | grep -v 'presuite.*backup' || true" > /tmp/crontab_temp
    echo "0 2 * * * ${MONITORING_PATH}/backups/backup.sh >> /var/log/presuite-backup.log 2>&1" >> /tmp/crontab_temp
    ssh "$server" "crontab -" < /tmp/crontab_temp
    rm /tmp/crontab_temp

    log "Cron configured on ${name}"
}

main() {
    log "Starting monitoring deployment..."

    # Deploy to all servers
    deploy_to_server "$PRESUITE_SERVER" "PreSuite Hub"
    deploy_to_server "$PREDRIVE_SERVER" "PreDrive"
    deploy_to_server "$PREMAIL_SERVER" "PreMail"
    deploy_to_server "$PREOFFICE_SERVER" "PreOffice"

    # Setup cron on primary backup server (PreSuite Hub)
    setup_cron "$PRESUITE_SERVER" "PreSuite Hub"

    log "Deployment complete!"
}

main "$@"
