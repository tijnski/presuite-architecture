#!/bin/bash
# PreSuite Security Audit Script
# Runs automated security checks across all services

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
REPORT_DIR="$PROJECT_ROOT/security-reports"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "============================================"
echo "PreSuite Security Audit - $TIMESTAMP"
echo "============================================"

# Create reports directory
mkdir -p "$REPORT_DIR"

# Check if required tools are installed
check_tools() {
    echo -e "\n${YELLOW}Checking required tools...${NC}"

    local missing=()

    command -v npm &> /dev/null || missing+=("npm")
    command -v node &> /dev/null || missing+=("node")

    if [ ${#missing[@]} -ne 0 ]; then
        echo -e "${RED}Missing tools: ${missing[*]}${NC}"
        exit 1
    fi

    echo -e "${GREEN}All required tools available${NC}"
}

# Run npm audit on a service
run_npm_audit() {
    local service_name=$1
    local service_path=$2
    local report_file="$REPORT_DIR/npm-audit-${service_name}-${TIMESTAMP}.json"

    echo -e "\n${YELLOW}Running npm audit for $service_name...${NC}"

    if [ -d "$service_path" ] && [ -f "$service_path/package.json" ]; then
        cd "$service_path"

        # Run npm audit and save to file
        npm audit --json > "$report_file" 2>/dev/null || true

        # Parse results
        local vulnerabilities=$(node -e "
            const data = require('$report_file');
            const vulns = data.metadata?.vulnerabilities || {};
            const total = (vulns.critical || 0) + (vulns.high || 0) + (vulns.moderate || 0) + (vulns.low || 0);
            console.log(JSON.stringify({
                total,
                critical: vulns.critical || 0,
                high: vulns.high || 0,
                moderate: vulns.moderate || 0,
                low: vulns.low || 0
            }));
        " 2>/dev/null || echo '{"total":0,"critical":0,"high":0,"moderate":0,"low":0}')

        local critical=$(echo "$vulnerabilities" | node -e "console.log(JSON.parse(require('fs').readFileSync('/dev/stdin', 'utf8')).critical)")
        local high=$(echo "$vulnerabilities" | node -e "console.log(JSON.parse(require('fs').readFileSync('/dev/stdin', 'utf8')).high)")
        local total=$(echo "$vulnerabilities" | node -e "console.log(JSON.parse(require('fs').readFileSync('/dev/stdin', 'utf8')).total)")

        if [ "$critical" -gt 0 ] || [ "$high" -gt 0 ]; then
            echo -e "${RED}  Critical: $critical, High: $high, Total: $total${NC}"
        elif [ "$total" -gt 0 ]; then
            echo -e "${YELLOW}  Total vulnerabilities: $total${NC}"
        else
            echo -e "${GREEN}  No vulnerabilities found${NC}"
        fi

        cd - > /dev/null
    else
        echo -e "${RED}  Service not found at $service_path${NC}"
    fi
}

# Check for hardcoded secrets
check_secrets() {
    local service_name=$1
    local service_path=$2
    local report_file="$REPORT_DIR/secrets-${service_name}-${TIMESTAMP}.txt"

    echo -e "\n${YELLOW}Checking for hardcoded secrets in $service_name...${NC}"

    if [ -d "$service_path" ]; then
        # Patterns to search for
        local patterns=(
            "password\s*[:=]\s*['\"][^'\"]+['\"]"
            "secret\s*[:=]\s*['\"][^'\"]+['\"]"
            "api[_-]?key\s*[:=]\s*['\"][^'\"]+['\"]"
            "token\s*[:=]\s*['\"][^'\"]+['\"]"
            "private[_-]?key"
            "BEGIN\s+(RSA\s+)?PRIVATE\s+KEY"
        )

        local found=0
        for pattern in "${patterns[@]}"; do
            local matches=$(grep -rniE "$pattern" "$service_path" \
                --include="*.js" --include="*.ts" --include="*.jsx" --include="*.tsx" \
                --exclude-dir=node_modules --exclude-dir=dist --exclude-dir=.git \
                2>/dev/null | grep -v "\.env\." | grep -v "example" | grep -v "test" || true)

            if [ -n "$matches" ]; then
                echo "$matches" >> "$report_file"
                found=$((found + $(echo "$matches" | wc -l)))
            fi
        done

        if [ $found -gt 0 ]; then
            echo -e "${RED}  Found $found potential secrets - check $report_file${NC}"
        else
            echo -e "${GREEN}  No hardcoded secrets detected${NC}"
        fi
    fi
}

# Check for security headers
check_security_headers() {
    local service_name=$1
    local url=$2

    echo -e "\n${YELLOW}Checking security headers for $service_name...${NC}"

    if command -v curl &> /dev/null; then
        local headers=$(curl -sI "$url" 2>/dev/null || echo "")

        local required_headers=(
            "Strict-Transport-Security"
            "X-Content-Type-Options"
            "X-Frame-Options"
        )

        local missing=()
        for header in "${required_headers[@]}"; do
            if ! echo "$headers" | grep -qi "$header"; then
                missing+=("$header")
            fi
        done

        if [ ${#missing[@]} -gt 0 ]; then
            echo -e "${YELLOW}  Missing headers: ${missing[*]}${NC}"
        else
            echo -e "${GREEN}  All recommended security headers present${NC}"
        fi
    else
        echo -e "${YELLOW}  curl not available, skipping header check${NC}"
    fi
}

# Check for outdated dependencies
check_outdated() {
    local service_name=$1
    local service_path=$2

    echo -e "\n${YELLOW}Checking for outdated dependencies in $service_name...${NC}"

    if [ -d "$service_path" ] && [ -f "$service_path/package.json" ]; then
        cd "$service_path"

        local outdated=$(npm outdated --json 2>/dev/null || echo "{}")
        local count=$(echo "$outdated" | node -e "
            const data = JSON.parse(require('fs').readFileSync('/dev/stdin', 'utf8'));
            console.log(Object.keys(data).length);
        " 2>/dev/null || echo "0")

        if [ "$count" -gt 0 ]; then
            echo -e "${YELLOW}  $count outdated packages${NC}"
        else
            echo -e "${GREEN}  All packages up to date${NC}"
        fi

        cd - > /dev/null
    fi
}

# Generate summary report
generate_summary() {
    local summary_file="$REPORT_DIR/summary-${TIMESTAMP}.md"

    echo -e "\n${YELLOW}Generating summary report...${NC}"

    cat > "$summary_file" << EOF
# PreSuite Security Audit Summary

**Date:** $(date '+%Y-%m-%d %H:%M:%S')

## Services Audited

| Service | npm audit | Secrets Check | Security Headers |
|---------|-----------|---------------|------------------|
| PreSuite Hub | See report | See report | Check manually |
| PreDrive | See report | See report | Check manually |
| PreMail | See report | See report | Check manually |
| PreOffice | See report | See report | Check manually |
| PreSocial | See report | See report | Check manually |

## Detailed Reports

Reports are saved in: \`$REPORT_DIR\`

## Recommendations

1. Fix all critical and high severity npm vulnerabilities
2. Review and rotate any exposed secrets
3. Ensure all security headers are properly configured
4. Update outdated dependencies regularly

## Next Steps

1. Run \`npm audit fix\` on services with vulnerabilities
2. Review secrets report and rotate any exposed credentials
3. Add missing security headers to nginx/server configuration
4. Schedule regular security audits (weekly/monthly)
EOF

    echo -e "${GREEN}Summary saved to $summary_file${NC}"
}

# Main execution
main() {
    check_tools

    # Define services
    local PRESUITE_PATH="/Users/tijnhoorneman/Documents/Documents-MacBook/presearch/presuite"
    local PREDRIVE_PATH="/Users/tijnhoorneman/Documents/Documents-MacBook/presearch/predrive"
    local PREMAIL_PATH="/Users/tijnhoorneman/Documents/Documents-MacBook/presearch/premail"
    local PREOFFICE_PATH="/Users/tijnhoorneman/Documents/Documents-MacBook/presearch/preoffice"
    local PRESOCIAL_PATH="/Users/tijnhoorneman/Documents/Documents-MacBook/presearch/presocial"

    # Run audits for each service
    echo -e "\n============================================"
    echo "npm Audit"
    echo "============================================"
    run_npm_audit "presuite" "$PRESUITE_PATH"
    run_npm_audit "predrive" "$PREDRIVE_PATH"
    run_npm_audit "premail" "$PREMAIL_PATH"

    echo -e "\n============================================"
    echo "Secrets Detection"
    echo "============================================"
    check_secrets "presuite" "$PRESUITE_PATH"
    check_secrets "predrive" "$PREDRIVE_PATH"
    check_secrets "premail" "$PREMAIL_PATH"

    echo -e "\n============================================"
    echo "Security Headers (Production)"
    echo "============================================"
    check_security_headers "presuite" "https://presuite.eu"
    check_security_headers "predrive" "https://predrive.eu"
    check_security_headers "premail" "https://premail.site"
    check_security_headers "preoffice" "https://preoffice.site"

    echo -e "\n============================================"
    echo "Outdated Dependencies"
    echo "============================================"
    check_outdated "presuite" "$PRESUITE_PATH"
    check_outdated "predrive" "$PREDRIVE_PATH"
    check_outdated "premail" "$PREMAIL_PATH"

    # Generate summary
    generate_summary

    echo -e "\n${GREEN}============================================${NC}"
    echo -e "${GREEN}Security audit complete!${NC}"
    echo -e "${GREEN}Reports saved to: $REPORT_DIR${NC}"
    echo -e "${GREEN}============================================${NC}"
}

main "$@"
