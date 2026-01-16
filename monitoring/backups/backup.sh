#!/bin/bash
#
# PreSuite Backup Script
# Backs up databases and files for all PreSuite services
#

set -euo pipefail

# Configuration
BACKUP_ROOT="${BACKUP_ROOT:-/opt/presuite-backups}"
RETENTION_DAYS="${RETENTION_DAYS:-30}"
DATE=$(date +%Y-%m-%d_%H-%M-%S)
LOG_FILE="${BACKUP_ROOT}/logs/backup_${DATE}.log"

# Service configurations
PRESUITE_DB_HOST="${PRESUITE_DB_HOST:-localhost}"
PRESUITE_DB_NAME="${PRESUITE_DB_NAME:-presuite}"
PRESUITE_DB_USER="${PRESUITE_DB_USER:-presuite}"

PREDRIVE_DB_HOST="${PREDRIVE_DB_HOST:-localhost}"
PREDRIVE_DB_NAME="${PREDRIVE_DB_NAME:-predrive}"
PREDRIVE_DB_USER="${PREDRIVE_DB_USER:-predrive}"
PREDRIVE_STORAGE_PATH="${PREDRIVE_STORAGE_PATH:-/opt/predrive/storage}"

PREMAIL_DB_HOST="${PREMAIL_DB_HOST:-localhost}"
PREMAIL_DB_NAME="${PREMAIL_DB_NAME:-stalwart}"
PREMAIL_DB_USER="${PREMAIL_DB_USER:-stalwart}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_info() {
    log "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    log "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    log "${RED}[ERROR]${NC} $1"
}

# Create backup directories
setup_directories() {
    log_info "Setting up backup directories..."
    mkdir -p "${BACKUP_ROOT}/databases/presuite"
    mkdir -p "${BACKUP_ROOT}/databases/predrive"
    mkdir -p "${BACKUP_ROOT}/databases/premail"
    mkdir -p "${BACKUP_ROOT}/files/predrive"
    mkdir -p "${BACKUP_ROOT}/logs"
}

# Backup PostgreSQL database
backup_postgres() {
    local name="$1"
    local host="$2"
    local database="$3"
    local user="$4"
    local output_dir="$5"
    local backup_file="${output_dir}/${name}_${DATE}.sql.gz"

    log_info "Backing up PostgreSQL database: ${name}..."

    if PGPASSWORD="${!name^^}_DB_PASSWORD:-}" pg_dump \
        -h "$host" \
        -U "$user" \
        -d "$database" \
        --no-owner \
        --no-acl \
        2>> "$LOG_FILE" | gzip > "$backup_file"; then

        local size=$(du -h "$backup_file" | cut -f1)
        log_info "Database backup completed: ${backup_file} (${size})"
        return 0
    else
        log_error "Failed to backup database: ${name}"
        return 1
    fi
}

# Backup SQLite database
backup_sqlite() {
    local name="$1"
    local db_path="$2"
    local output_dir="$3"
    local backup_file="${output_dir}/${name}_${DATE}.sqlite.gz"

    log_info "Backing up SQLite database: ${name}..."

    if [ -f "$db_path" ]; then
        if sqlite3 "$db_path" ".backup /tmp/${name}_backup.sqlite" 2>> "$LOG_FILE" && \
           gzip -c "/tmp/${name}_backup.sqlite" > "$backup_file"; then
            rm -f "/tmp/${name}_backup.sqlite"
            local size=$(du -h "$backup_file" | cut -f1)
            log_info "Database backup completed: ${backup_file} (${size})"
            return 0
        else
            log_error "Failed to backup database: ${name}"
            return 1
        fi
    else
        log_warn "Database file not found: ${db_path}"
        return 1
    fi
}

# Backup files/directories
backup_files() {
    local name="$1"
    local source_path="$2"
    local output_dir="$3"
    local backup_file="${output_dir}/${name}_${DATE}.tar.gz"

    log_info "Backing up files: ${name}..."

    if [ -d "$source_path" ]; then
        if tar -czf "$backup_file" -C "$(dirname "$source_path")" "$(basename "$source_path")" 2>> "$LOG_FILE"; then
            local size=$(du -h "$backup_file" | cut -f1)
            log_info "File backup completed: ${backup_file} (${size})"
            return 0
        else
            log_error "Failed to backup files: ${name}"
            return 1
        fi
    else
        log_warn "Source directory not found: ${source_path}"
        return 1
    fi
}

# Clean up old backups
cleanup_old_backups() {
    log_info "Cleaning up backups older than ${RETENTION_DAYS} days..."

    find "${BACKUP_ROOT}/databases" -type f -mtime +${RETENTION_DAYS} -delete 2>> "$LOG_FILE" || true
    find "${BACKUP_ROOT}/files" -type f -mtime +${RETENTION_DAYS} -delete 2>> "$LOG_FILE" || true
    find "${BACKUP_ROOT}/logs" -type f -mtime +${RETENTION_DAYS} -delete 2>> "$LOG_FILE" || true

    log_info "Cleanup completed"
}

# Upload to remote storage (S3-compatible)
upload_to_s3() {
    local source="$1"
    local bucket="${S3_BUCKET:-}"
    local endpoint="${S3_ENDPOINT:-}"

    if [ -z "$bucket" ]; then
        log_warn "S3_BUCKET not configured, skipping remote upload"
        return 0
    fi

    log_info "Uploading backups to S3..."

    local s3_cmd="aws s3"
    if [ -n "$endpoint" ]; then
        s3_cmd="aws s3 --endpoint-url $endpoint"
    fi

    if $s3_cmd sync "$source" "s3://${bucket}/presuite-backups/" \
        --exclude "*.log" \
        2>> "$LOG_FILE"; then
        log_info "S3 upload completed"
        return 0
    else
        log_error "S3 upload failed"
        return 1
    fi
}

# Send notification
send_notification() {
    local status="$1"
    local message="$2"
    local webhook_url="${ALERT_WEBHOOK_URL:-}"

    if [ -z "$webhook_url" ]; then
        return 0
    fi

    local color="good"
    if [ "$status" = "error" ]; then
        color="danger"
    elif [ "$status" = "warning" ]; then
        color="warning"
    fi

    curl -s -X POST "$webhook_url" \
        -H 'Content-Type: application/json' \
        -d "{
            \"attachments\": [{
                \"color\": \"${color}\",
                \"title\": \"PreSuite Backup ${status^}\",
                \"text\": \"${message}\",
                \"footer\": \"PreSuite Backup System\",
                \"ts\": $(date +%s)
            }]
        }" > /dev/null 2>&1 || true
}

# Calculate backup summary
generate_summary() {
    log_info "Generating backup summary..."

    local total_size=$(du -sh "${BACKUP_ROOT}" 2>/dev/null | cut -f1)
    local db_count=$(find "${BACKUP_ROOT}/databases" -name "*${DATE}*" -type f 2>/dev/null | wc -l)
    local file_count=$(find "${BACKUP_ROOT}/files" -name "*${DATE}*" -type f 2>/dev/null | wc -l)

    echo ""
    log_info "=== Backup Summary ==="
    log_info "Date: ${DATE}"
    log_info "Database backups: ${db_count}"
    log_info "File backups: ${file_count}"
    log_info "Total backup size: ${total_size}"
    log_info "====================="
}

# Main backup routine
main() {
    local start_time=$(date +%s)
    local errors=0

    log_info "Starting PreSuite backup..."

    # Setup
    setup_directories

    # Backup databases
    log_info "=== Database Backups ==="

    # PreSuite Hub (if PostgreSQL)
    backup_postgres "presuite" "$PRESUITE_DB_HOST" "$PRESUITE_DB_NAME" "$PRESUITE_DB_USER" \
        "${BACKUP_ROOT}/databases/presuite" || ((errors++))

    # PreDrive
    backup_postgres "predrive" "$PREDRIVE_DB_HOST" "$PREDRIVE_DB_NAME" "$PREDRIVE_DB_USER" \
        "${BACKUP_ROOT}/databases/predrive" || ((errors++))

    # PreMail (Stalwart)
    backup_postgres "premail" "$PREMAIL_DB_HOST" "$PREMAIL_DB_NAME" "$PREMAIL_DB_USER" \
        "${BACKUP_ROOT}/databases/premail" || ((errors++))

    # Backup files
    log_info "=== File Backups ==="

    # PreDrive storage
    backup_files "predrive_storage" "$PREDRIVE_STORAGE_PATH" "${BACKUP_ROOT}/files/predrive" || ((errors++))

    # Cleanup
    cleanup_old_backups

    # Upload to remote storage
    upload_to_s3 "${BACKUP_ROOT}"

    # Generate summary
    generate_summary

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    if [ $errors -eq 0 ]; then
        log_info "Backup completed successfully in ${duration} seconds"
        send_notification "success" "Backup completed successfully in ${duration} seconds"
    else
        log_error "Backup completed with ${errors} errors in ${duration} seconds"
        send_notification "error" "Backup completed with ${errors} errors"
        exit 1
    fi
}

# Run backup
main "$@"
