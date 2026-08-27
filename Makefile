.PHONY: all build test lint run

all: build

build:
	go build -o bin/server ./cmd/server

test:
	go test -v ./...

lint:
	golangci-lint run

run:
	go run ./cmd/server
