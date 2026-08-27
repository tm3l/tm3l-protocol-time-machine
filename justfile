# TM3L Protocol Time Machine — Polyglot Task Runner

set shell := ["bash", "-c"]

default:
	@just --list

up:
	./scripts/up.sh

down:
	./scripts/down.sh

restart:
	./scripts/restart.sh

logs:
	docker compose logs -f

health:
	./scripts/healthcheck.sh

preflight:
	./scripts/preflight.sh

gen-secrets:
	./scripts/generate-secrets.sh

test: test-server test-explorer
	@echo "All Protocol Time Machine test suites passed successfully."

test-server:
	@echo "==> Running Go Server tests..."
	go test -race -coverprofile=coverage.out ./...

test-explorer:
	@echo "==> Building React/D3 Explorer..."
	cd explorer && npm run build

lint: lint-server lint-explorer
	@echo "All Protocol Time Machine lint checks passed."

lint-server:
	@echo "==> Linting Go Server..."
	go vet ./...

lint-explorer:
	@echo "==> Typechecking Explorer UI..."
	cd explorer && npx tsc -b --noEmit

build:
	@echo "==> Building Go Binary..."
	go build -o bin/protocol-tm ./cmd/...
	@echo "==> Building Explorer UI..."
	cd explorer && npm run build
