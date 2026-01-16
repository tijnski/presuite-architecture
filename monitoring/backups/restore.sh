#!/bin/bash
#
# PreSuite Restore Script
# Restores databases and files from backups
#

set -euo pipefail

# Configuration
BACKUP_ROOT="${BACKUP_ROOT:-/opt/presuite-backups}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
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

# List available backups
list_backups() {
    local service="${1:-}"

    echo ""
    echo "Available Backups:"
    echo "=================="

    if [ -z "$service" ] || [ "$service" = "presuite" ]; then
        echo ""
        echo "PreSuite Hub:"
        ls -lh "${BACKUP_ROOT}/databases/presuite/"*.gz 2>/dev/null | tail -10 || echo "  No backups found"
    fi

    if [ -z "$service" ] || [ "$service" = "predrive" ]; then
        echo ""
        echo "PreDrive Databases:"
        ls -lh "${BACKUP_ROOT}/databases/predrive/"*.gz 2>/dev/null | tail -10 || echo "  No backups found"
        echo ""
        echo "PreDrive Files:"
        ls -lh "${BACKUP_ROOT}/files/predrive/"*.tar.gz 2>/dev/null | tail -10 || echo "  No backups found"
    fi

    if [ -z "$service" ] || [ "$service" = "premail" ]; then
        echo ""
        echo "PreMail:"
        ls -lh "${BACKUP_ROOT}/databases/premail/"*.gz 2>/dev/null | tail -10 || echo "  No backups found"
    fi

    echo ""
}

# Restore PostgreSQL database
restore_postgres() {
    local backup_file="$1"
    local host="$2"
    local database="$3"
    local user="$4"
    local password_var="$5"

    if [ ! -f "$backup_file" ]; then
        log_error "Backup file not found: ${backup_file}"
        return 1
    fi

    log_warn "This will OVERWRITE the database: ${database}"
    read -p "Are you sure you want to continue? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        log_info "Restore cancelled"
        return 0
    fi

    log_info "Restoring database from: ${backup_file}"

    # Create temp file for decompressed backup
    local temp_file=$(mktemp)

    if gunzip -c "$backup_file" > "$temp_file"; then
        if PGPASSWORD="${!password_var:-}" psql \
            -h "$host" \
            -U "$user" \
            -d "$database" \
            -f "$temp_file"; then
            log_info "Database restored successfully"
            rm -f "$temp_file"
            return 0
        else
            log_error "Failed to restore database"
            rm -f "$temp_file"
            return 1
        fi
    else
        log_error "Failed to decompress backup"
        rm -f "$temp_file"
        return 1
    fi
}

# Restore files
restore_files() {
    local backup_file="$1"
    local target_path="$2"

    if [ ! -f "$backup_file" ]; then
        log_error "Backup file not found: ${backup_file}"
        return 1
    fi

    log_warn "This will OVERWRITE files in: ${target_path}"
    read -p "Are you sure you want to continue? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        log_info "Restore cancelled"
        return 0
    fi

    log_info "Restoring files from: ${backup_file}"

    # Backup current files first
    if [ -d "$target_path" ]; then
        local backup_current="${target_path}.pre-restore.$(date +%Y%m%d%H%M%S)"
        log_info "Backing up current files to: ${backup_current}"
        mv "$target_path" "$backup_current"
    fi

    mkdir -p "$(dirname "$target_path")"

    if tar -xzf "$backup_file" -C "$(dirname "$target_path")"; then
        log_info "Files restored successfully"
        return 0
    else
        log_error "Failed to restore files"
        # Try to restore original
        if [ -d "$backup_current" ]; then
            mv "$backup_current" "$target_path"
        fi
        return 1
    fi
}

# Download from S3
download_from_s3() {
    local remote_path="$1"
    local local_path="$2"
    local bucket="${S3_BUCKET:-}"
    local endpoint="${S3_ENDPOINT:-}"

    if [ -z "$bucket" ]; then
        log_error "S3_BUCKET not configured"
        return 1
    fi

    log_info "Downloading from S3: ${remote_path}"

    local s3_cmd="aws s3"
    if [ -n "$endpoint" ]; then
        s3_cmd="aws s3 --endpoint-url $endpoint"
    fi

    if $s3_cmd cp "s3://${bucket}/${remote_path}" "$local_path"; then
        log_info "Download completed"
        return 0
    else
        log_error "Download failed"
        return 1
    fi
}

# Show usage
usage() {
    cat << EOF
PreSuite Restore Script

Usage: $0 <command> [options]

Commands:
  list [service]              List available backups
  restore-db <service> <file> Restore a database backup
  restore-files <file> <path> Restore a file backup
  download <s3-path> <local>  Download backup from S3

Services: presuite, predrive, premail

Examples:
  $0 list
  $0 list predrive
  $0 restore-db predrive /opt/presuite-backups/databases/predrive/predrive_2026-01-16.sql.gz
  $0 restore-files /opt/presuite-backups/files/predrive/storage_2026-01-16.tar.gz /opt/predrive/storage
EOF
}

# Main
main() {
    local command="${1:-}"

    case "$command" in
        list)
            list_backups "${2:-}"
            ;;
        restore-db)
            if [ $# -lt 3 ]; then
                log_error "Usage: $0 restore-db <service> <backup-file>"
                exit 1
            fi
            local service="$2"
            local backup_file="$3"
            case "$service" in
                presuite)
                    restore_postgres "$backup_file" \
                        "${PRESUITE_DB_HOST:-localhost}" \
                        "${PRESUITE_DB_NAME:-presuite}" \
                        "${PRESUITE_DB_USER:-presuite}" \
                        "PRESUITE_DB_PASSWORD"
                    ;;
                predrive)
                    restore_postgres "$backup_file" \
                        "${PREDRIVE_DB_HOST:-localhost}" \
                        "${PREDRIVE_DB_NAME:-predrive}" \
                        "${PREDRIVE_DB_USER:-predrive}" \
                        "PREDRIVE_DB_PASSWORD"
                    ;;
                premail)
                    restore_postgres "$backup_file" \
                        "${PREMAIL_DB_HOST:-localhost}" \
                        "${PREMAIL_DB_NAME:-stalwart}" \
                        "${PREMAIL_DB_USER:-stalwart}" \
                        "PREMAIL_DB_PASSWORD"
                    ;;
                *)
                    log_error "Unknown service: $service"
                    exit 1
                    ;;
            esac
            ;;
        restore-files)
            if [ $# -lt 3 ]; then
                log_error "Usage: $0 restore-files <backup-file> <target-path>"
                exit 1
            fi
            restore_files "$2" "$3"
            ;;
        download)
            if [ $# -lt 3 ]; then
                log_error "Usage: $0 download <s3-path> <local-path>"
                exit 1
            fi
            download_from_s3 "$2" "$3"
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            usage
            exit 1
            ;;
    esac
}

main "$@"
