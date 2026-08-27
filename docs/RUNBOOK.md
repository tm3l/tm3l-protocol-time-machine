# TM3L Protocol Time Machine — Operational Runbook

## 1. Quick Start & Triage
```bash
just preflight
just up
just health
just logs
```

## 2. Port Architecture
- **Go API Server**: `http://localhost:8084`
- **React / D3 Timeline Explorer**: `http://localhost:5176`
- **PostgreSQL Database**: `localhost:5435`

## 3. Incident Playbooks
- **Schema Snapshot Ingestion Lag**: Check ingestion queue logs with `just logs`.
- **Database Connection Reset**: Run `just health` to verify PostgreSQL status.
