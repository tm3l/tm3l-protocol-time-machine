# ⏳ Protocol Time Machine

**Interactive visual history of how Internet protocols actually evolved — and why.**

[![Project Status: Under Construction](https://img.shields.io/badge/status-🚧%20under%20construction-yellow.svg)](https://github.com/tm3l/protocol-time-machine)
[![Go Version](https://img.shields.io/badge/go-1.23-blue.svg)](https://golang.org)
[![React Version](https://img.shields.io/badge/react-19-61dafb.svg)](https://react.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## Overview

The modern Internet runs on thousands of Requests for Comments (RFCs) published over more than five decades by the IETF. Understanding why protocols are designed the way they are requires navigating a complex web of "updates", "obsoletes", and "references" relationships dating back to ARPANET in 1969.

**Protocol Time Machine** ingests the official IETF RFC index, constructs a directed evolution graph, and renders an interactive visual explorer. Travel back in time, trace protocol lineages, and inspect the exact historical RFC clauses that motivated architectural shifts.

---

## 🌟 The Demo Moment

> **Click on HTTP/3.**
> See the full visual tree of how it connects back to the original TCP RFC in 1981 (RFC 793), through SPDY, HTTP/2 (RFC 7540), and QUIC (RFC 9000). Click any node to inspect the source evidence, obsoleted sections, and structural diffs across decades of protocol evolution.

---

## Features

- **IETF RFC Ingestion Engine**: Automated, resilient ingestion of the complete IETF RFC index and metadata snapshots.
- **Protocol Relationship Graph**: Complete directed acyclic graph mapping `Obsoletes`, `Obsoleted-By`, `Updates`, `Updated-By`, and normative `References` across 9,000+ RFCs.
- **Interactive Timeline (1969 – Present)**: Scrub through decades of network protocol milestones from NCP and early TCP/IP to modern TLS 1.3, QUIC, and HTTP/3.
- **Evidence-Backed Explorer**: Direct citations, errata links, and line-level diff references extracted straight from primary IETF sources.
- **Shareable URLs**: Deep link directly to exact graph states, subtrees, or protocol comparison diffs for documentation and education.

---

## Architecture

```text
┌─────────────────────────┐
│     IETF RFC Index      │ (Official XML / JSON / Text Feeds)
└────────────┬────────────┘
             │ Ingestion Worker
             ▼
┌─────────────────────────┐
│     Go Ingester         │ (Streaming parser, relation extractor)
└────────────┬────────────┘
             │ Persist Graph & Metadata
             ▼
┌─────────────────────────┐
│       PostgreSQL        │ (RFC entities, DAG edges, full-text search)
└────────────┬────────────┘
             │ High-performance JSON / Graph APIs
             ▼
┌─────────────────────────┐
│        Go API           │ (REST endpoints + templ/HTMX Admin)
└────────────┬────────────┘
             │ Query graph & node details
             ▼
┌─────────────────────────┐
│     React Explorer      │ (Hero UI: D3 force/tree layout, timeline scrubber)
└─────────────────────────┘
```

---

## Tech Stack

| Layer | Technology | Rationale |
|---|---|---|
| **Backend & Ingestion** | Go 1.23 | Fast streaming parsers, concurrent network fetching, minimal memory footprint, and low-latency API responses. |
| **Database** | PostgreSQL 16 | Relational consistency with JSONB support and recursive CTEs for efficient graph traversal of RFC relationships. |
| **Admin Views** | Go `templ` + HTMX | Zero-friction, lightweight internal admin dashboard for monitoring ingestion jobs and RFC errata updates. |
| **Interactive Explorer** | React 19 + TypeScript + Vite + D3 | Rich client-side graph rendering, responsive timeline controls, and declarative UI state. |

### Why Go + React Only? (No Python or Rust Needed)

- **Why no Python?** Python is often chosen for text parsing and data pipelines, but Go's standard library and concurrency primitives (`goroutines`, `channels`, `errgroup`) handle multi-threaded RFC fetching and XML/JSON parsing faster with single-binary deployment and predictable low memory usage.
- **Why no Rust?** Rust excels in low-level systems programming, but RFC graph extraction is I/O-bound and relational. Go delivers exceptional performance and fast compilation cycles without the cognitive overhead of manual lifetime management or WebAssembly boundary serialization. D3 + Canvas/SVG in React runs entirely in-browser at 60 FPS.

---

## Quick Start

### Prerequisites

- Docker and Docker Compose
- Go 1.23+ (for local backend development)
- Node.js 20+ and npm/pnpm (for local frontend development)

### Run with Docker Compose

```bash
docker compose up
```

- **React Explorer**: [http://localhost:5173](http://localhost:5173)
- **Go API Server**: [http://localhost:8080](http://localhost:8080)
- **API Documentation**: [http://localhost:8080/swagger](http://localhost:8080/swagger)

---

## Project Structure

```text
protocol-time-machine/
├── cmd/
│   └── server/             # Application entry point
├── internal/
│   ├── api/                # HTTP API handlers & middleware
│   ├── ingest/             # IETF RFC index ingestion & parsers
│   ├── rfc/                # Core RFC metadata & domain models
│   ├── relations/          # Graph traversal (updates/obsoletes/references)
│   ├── store/              # PostgreSQL repository layer & queries
│   └── web/                # templ + HTMX admin dashboard views
├── api/                    # OpenAPI specifications
├── explorer/               # React 19 + D3 interactive graph explorer
├── migrations/             # SQL database migration scripts
├── deploy/                 # Dockerfile and Kubernetes manifests
├── docs/                   # Architecture documentation & ADRs
└── data/                   # RFC index snapshot fixtures & seed files
```

---

## Development

```bash
# Build Go server and frontend
make build

# Run tests
make test

# Start PostgreSQL and dependencies
make docker-up

# Stop all containers
make docker-down
```

---

## License

This project is licensed under the [MIT License](LICENSE).
