.PHONY: all build build-server build-explorer test test-server test-explorer lint clean docker-up docker-down

all: build

## Build targets
build: build-server build-explorer

build-server:
	@echo "Building Go server..."
	go build -o bin/server ./cmd/server

build-explorer:
	@echo "Building Explorer frontend..."
	cd explorer && npm run build

## Test targets
test: test-server test-explorer

test-server:
	@echo "Running Go tests..."
	go test -v -race ./...

test-explorer:
	@echo "Running Explorer tests..."
	cd explorer && npm test --if-present

## Linting
lint:
	@echo "Linting Go codebase..."
	golangci-lint run ./... || true
	@echo "Linting Explorer frontend..."
	cd explorer && npm run lint --if-present

## Docker Compose targets
docker-up:
	docker compose up -d

docker-down:
	docker compose down

## Clean
clean:
	rm -rf bin/ dist/ explorer/dist/
