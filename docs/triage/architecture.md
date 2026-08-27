# Protocol Time Machine Architecture

## 1. System Overview

**Protocol Time Machine** is an interactive visual system that maps, analyzes, and explores the historical evolution of Internet protocols from 1969 to the present day.

The architecture comprises four primary pipeline stages:
1. **Ingestion Engine**: Extracts structured metadata from official IETF feeds and RFC archives.
2. **Storage & Graph Layer**: Persists RFC records, status transitions, and relational edges in PostgreSQL with recursive graph traversal.
3. **API & Admin Layer**: High-throughput Go REST API for graph queries paired with `templ` + HTMX internal administration views.
4. **Interactive Explorer**: React 19 + D3 client-side application delivering 60 FPS graph navigation and timeline scrubbing.

```text
┌─────────────────────────────────────────────────────────────┐
│                      Data Pipeline                          │
└─────────────────────────────────────────────────────────────┘

  [ IETF RFC Index ] (XML / JSON / Raw Text)
          │
          ▼ (Streaming Worker Pool)
  [ Go Ingest Engine ]
    ├── Metadata Extractor (Status, Date, WG, Authors)
    ├── Relationship Builder (Updates, Obsoletes, References)
    └── Line Diff Analyzer (Structural RFC changes)
          │
          ▼ (Batch Inserts / Upserts)
  [ PostgreSQL 16 ]
    ├── Entities: `rfcs`, `authors`, `working_groups`
    ├── Graph Edges: `rfc_relations` (source, target, relation_type)
    └── Search: `tsvector` full-text index
          │
          ▼ (HTTP / JSON / CTE Traversals)
  [ Go API Server ] ──────────────► [ templ + HTMX Admin Dashboard ]
          │
          ▼ (JSON Graph Subtree / Timeline)
  [ React 19 Explorer ] (D3 Graph Canvas + Timeline Slider)
```

---

## 2. End-to-End Data Pipeline

### Stage 1: Ingestion (`internal/ingest`)
- **Feed Source**: Fetches the official `rfc-index.xml` and individual RFC documents from `https://www.rfc-editor.org/`.
- **Parsing**: Streaming XML/JSON parser extracts RFC number, title, publication date, current status (Proposed Standard, Internet Standard, Informational, Best Current Practice, Historic), streams (IETF, IRTF, IAB, Independent), and abstract.
- **Relationship Extraction**: Parses bidirectional relations:
  - `Obsoletes` / `Obsoleted-By`
  - `Updates` / `Updated-By`
  - Normative and Informative `References`
  - `Also-Known-As` / Subseries (STD, BCP, FYI)

### Stage 2: Storage & Graph Queries (`internal/store`)
- PostgreSQL stores normalized entities alongside relational adjacency tables.
- Graph queries utilize PostgreSQL Recursive Common Table Expressions (CTEs) to resolve multi-hop ancestry and descendant trees in under 5ms:
  ```sql
  WITH RECURSIVE lineage AS (
    SELECT source_rfc, target_rfc, relation_type, 1 AS depth
    FROM rfc_relations
    WHERE source_rfc = $1
    UNION
    SELECT r.source_rfc, r.target_rfc, r.relation_type, l.depth + 1
    FROM rfc_relations r
    JOIN lineage l ON r.source_rfc = l.target_rfc
    WHERE l.depth < $2
  )
  SELECT * FROM lineage;
  ```

### Stage 3: API & Web Layer (`internal/api`, `internal/web`)
- **REST Endpoints**: Delivers JSON responses formatted specifically for client-side graph hydration (nodes and links array).
- **Admin Console**: Built using Go `templ` components and HTMX, allowing operators to trigger manual syncs, review ingestion anomalies, and inspect raw parsed trees without client-side bundle overhead.

### Stage 4: Interactive Explorer (`explorer/`)
- Client-side React 19 application utilizing D3.js for force-directed graph physics and hierarchical tree layouts.
- Dynamic timeline scrubber allows filtering nodes based on the state of the Internet in any given year between 1969 and today.

---

## 3. Technology Evaluation: Why Go + React Only?

A common question in graph data visualization projects is whether Python (for data pipelines) or Rust (for performance/WASM) should be included. Protocol Time Machine intentionally omits both.

### Why Not Python?
1. **Concurrency and Throughput**: Go's native goroutines and channels allow streaming and concurrent fetching of thousands of RFC documents with lower CPU/memory overhead than Python's `asyncio` or `multiprocessing`.
2. **Type Safety & Single Binary**: Go produces a single, self-contained binary without virtual environments, wheel dependencies, or runtime interpreter overhead.
3. **Data Processing Simplicity**: The IETF RFC data format is structured (XML/JSON); it does not require complex ML or Pandas transformations. Go's standard library `encoding/xml` and `encoding/json` are fast, robust, and type-safe.

### Why Not Rust?
1. **Workload Characteristics**: The ingestion pipeline is I/O-bound (network requests to IETF mirrors and database writes), not CPU-bound numerical computing. Go achieves sub-millisecond API response times and handles I/O concurrency with greater ergonomics.
2. **Frontend Graph Performance**: Rather than compiling complex Rust graph algorithms to WebAssembly, modern browser JavaScript engines running D3 force layouts can comfortably render 5,000+ nodes in SVG/Canvas at 60 FPS.
3. **Development Velocity**: Go's clean syntax and fast compilation cycles enable rapid iterations across domain models, migrations, and API contracts without Rust's borrow checker overhead for web services.

---

## 4. Directory Conventions

- `cmd/server/`: Application initialization and dependency injection.
- `internal/api/`: HTTP router, middleware, handlers, and JSON serializers.
- `internal/ingest/`: IETF HTTP clients, XML/JSON streaming parsers, and cron workers.
- `internal/rfc/`: Domain entities (`RFC`, `Status`, `WorkingGroup`, `Author`).
- `internal/relations/`: Directed graph data structures and lineage resolution.
- `internal/store/`: Database schema, migrations, connection pool, and repository queries.
- `internal/web/`: `templ` templates and HTMX handlers for the internal operations view.
- `explorer/`: React 19 Vite application hosting the D3 evolution explorer.
- `api/`: OpenAPI 3.1 specifications.
- `docs/adr/`: Architecture Decision Records.
