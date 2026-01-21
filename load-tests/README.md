# PreSuite Load Testing

Performance and load testing suite for PreSuite services using [k6](https://k6.io/).

## Prerequisites

Install k6:

```bash
# macOS
brew install k6

# Linux (Debian/Ubuntu)
sudo gpg -k
sudo gpg --no-default-keyring --keyring /usr/share/keyrings/k6-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747E3415A3642D57D77C6C491D6AC1D69
echo "deb [signed-by=/usr/share/keyrings/k6-archive-keyring.gpg] https://dl.k6.io/deb stable main" | sudo tee /etc/apt/sources.list.d/k6.list
sudo apt-get update
sudo apt-get install k6

# Windows
choco install k6

# Docker
docker pull grafana/k6
```

## Quick Start

```bash
# Run smoke tests (minimal load, verify functionality)
./run-tests.sh

# Run specific test
./run-tests.sh auth
./run-tests.sh predrive
./run-tests.sh premail
./run-tests.sh all-services

# Run with different scenarios
SCENARIO=load ./run-tests.sh all
SCENARIO=stress ./run-tests.sh auth
SCENARIO=spike ./run-tests.sh all-services

# Run with authentication (for full test coverage)
TEST_EMAIL=your@email.com TEST_PASSWORD=yourpass ./run-tests.sh all
```

## Test Scenarios

| Scenario | Description | VUs | Duration |
|----------|-------------|-----|----------|
| `smoke` | Verify functionality works | 1 | 30s |
| `load` | Normal expected traffic | 0→10→10→0 | 9min |
| `stress` | Find breaking point | 0→10→50→100→0 | 16min |
| `spike` | Sudden traffic surge | 0→100→0 | ~1.5min |

## Test Files

| File | Description |
|------|-------------|
| `scenarios/presuite-auth.js` | Authentication endpoints (login, verify, token) |
| `scenarios/predrive-files.js` | File operations (list, search, recent) |
| `scenarios/premail-inbox.js` | Email operations (accounts, messages, labels) |
| `scenarios/all-services.js` | Combined test hitting all services |
| `lib/config.js` | Shared configuration and thresholds |
| `lib/helpers.js` | Common utilities and helpers |

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SCENARIO` | `smoke` | Test scenario to run |
| `TEST_EMAIL` | - | Test user email for auth |
| `TEST_PASSWORD` | - | Test user password |
| `PRESUITE_URL` | `https://presuite.eu` | PreSuite Hub URL |
| `PREDRIVE_URL` | `https://predrive.eu` | PreDrive URL |
| `PREMAIL_URL` | `https://premail.site` | PreMail URL |
| `PREOFFICE_URL` | `https://preoffice.site` | PreOffice URL |

### Thresholds

Default performance thresholds:

- **P95 Response Time**: < 500ms
- **P99 Response Time**: < 1500ms
- **Error Rate**: < 1%
- **Check Pass Rate**: > 99%

Custom thresholds per test:
- Login duration P95: < 1000ms
- Inbox load P95: < 1000ms
- List operations: < 800ms

## Running Individual Tests

```bash
# Direct k6 execution with custom options
k6 run -e SCENARIO=load scenarios/presuite-auth.js

# With output to InfluxDB (for Grafana dashboards)
k6 run --out influxdb=http://localhost:8086/k6 scenarios/all-services.js

# With JSON output
k6 run --out json=results/output.json scenarios/predrive-files.js

# With specific VUs and duration (overrides scenario)
k6 run --vus 50 --duration 5m scenarios/all-services.js
```

## Results

Test results are saved to `results/` directory:
- `*-summary.json` - Full metrics and results
- Console output includes key metrics summary

## Creating a Test User

For authenticated tests, create a dedicated load test user:

```bash
# Via PreSuite registration (with a strong password)
curl -X POST https://presuite.eu/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"loadtest@premail.site","password":"LoadTest123!","name":"Load Test"}'
```

## Interpreting Results

### Key Metrics

| Metric | Good | Acceptable | Poor |
|--------|------|------------|------|
| P95 Response | < 200ms | < 500ms | > 500ms |
| Error Rate | < 0.1% | < 1% | > 1% |
| Throughput | Stable | Minor drops | Significant drops |

### Common Issues

1. **High P95 but low avg**: Occasional slow requests, check for specific endpoints
2. **Rising error rate under load**: Server reaching capacity limits
3. **Timeout errors**: Network issues or server overload
4. **Auth failures**: Check credentials or token expiry

## CI/CD Integration

Add to GitHub Actions:

```yaml
- name: Run Load Tests
  run: |
    curl -L https://github.com/grafana/k6/releases/download/v0.47.0/k6-v0.47.0-linux-amd64.tar.gz | tar xz
    ./k6-v0.47.0-linux-amd64/k6 run load-tests/scenarios/all-services.js
  env:
    SCENARIO: smoke
```

## Monitoring During Tests

While running tests, monitor:
- Server CPU/Memory (via SSH or monitoring dashboard)
- Database connections
- API logs for errors
- Network bandwidth

```bash
# Watch server resources during test
ssh root@76.13.2.221 "htop"

# Watch API logs
ssh root@76.13.2.221 "pm2 logs presuite --lines 50"
```
