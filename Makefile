# Config
BACKEND_DIR = backend
GO_BUILD_DIR = bin

.PHONY: build-api run-api help

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build-api: ## Build the Go API server
	@mkdir -p $(GO_BUILD_DIR)
	@cd $(BACKEND_DIR) && go build -o ../$(GO_BUILD_DIR)/api .

run-api: build-api ## Run the Go API server
	@bash -c "[ -f .env ] && set -a && source .env && set +a; $(GO_BUILD_DIR)/api"