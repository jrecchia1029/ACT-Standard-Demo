# Makefile for AVD Multi-Site Demo
# Simplified to Build and Deploy operations

.PHONY: help build deploy debug clean

# Default target
.DEFAULT_GOAL := help

# Variables
UV := uv
ANSIBLE := $(UV) run ansible-playbook
# Use absolute paths based on Makefile location
MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
DC_INVENTORY := $(MAKEFILE_DIR)sites/NY5-CH3/inventory.yml
SOMA_INVENTORY := $(MAKEFILE_DIR)sites/SF-SOMA/inventory.yml
FD_INVENTORY := $(MAKEFILE_DIR)sites/SF-FD/inventory.yml
BUILD_PLAYBOOK := $(MAKEFILE_DIR)playbooks/build.yml
DEPLOY_PLAYBOOK := $(MAKEFILE_DIR)playbooks/deploy.yml
VALIDATE_PLAYBOOK := $(MAKEFILE_DIR)playbooks/validate.yml

help: ## Display this help message
	@echo "AVD Multi-Site Demo - Available Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Examples:"
	@echo "  make build         # Build all sites"
	@echo "  make deploy        # Deploy all sites to CloudVision"

build: ## Build configurations for all sites (Datacenter, SF-SOMA, SF-FD)
	@echo "=========================================="
	@echo "Building AVD Configurations"
	@echo "=========================================="
	@echo ""
	@echo "→ Building Datacenter (NY5 & CH3)..."
	@$(ANSIBLE) $(BUILD_PLAYBOOK) -i $(DC_INVENTORY)
	@echo ""
	@echo "→ Building SF-SOMA Campus..."
	@$(ANSIBLE) $(BUILD_PLAYBOOK) -i $(SOMA_INVENTORY)
	@echo ""
	@echo "→ Building SF-FD Campus..."
	@$(ANSIBLE) $(BUILD_PLAYBOOK) -i $(FD_INVENTORY)
	@echo ""
	@echo "✅ All configurations built successfully!"
	@echo ""

deploy: ## Deploy configurations to CloudVision for all sites
	@echo "=========================================="
	@echo "Deploying to CloudVision"
	@echo "=========================================="
	@echo ""
	@echo "→ Deploying Datacenter (NY5 & CH3)..."
	@$(ANSIBLE) $(DEPLOY_PLAYBOOK) -i $(DC_INVENTORY)
	@echo ""
	@echo "→ Deploying SF-SOMA Campus..."
	@$(ANSIBLE) $(DEPLOY_PLAYBOOK) -i $(SOMA_INVENTORY)
	@echo ""
	@echo "→ Deploying SF-FD Campus..."
	@$(ANSIBLE) $(DEPLOY_PLAYBOOK) -i $(FD_INVENTORY)
	@echo ""
	@echo "✅ All configurations deployed successfully!"
	@echo ""

validate: ## Validate device state
	@echo "=========================================="
	@echo "Running ANTA validation tests"
	@echo "=========================================="
	@echo ""
	@echo "→ Validating Datacenter (NY5 & CH3)..."
	@$(ANSIBLE) $(VALIDATE_PLAYBOOK) -i $(DC_INVENTORY)
	@echo ""
	@echo "→ Validating SF-SOMA Campus..."
	@$(ANSIBLE) $(VALIDATE_PLAYBOOK) -i $(SOMA_INVENTORY)
	@echo ""
	@echo "→ Validating SF-FD Campus..."
	@$(ANSIBLE) $(VALIDATE_PLAYBOOK) -i $(FD_INVENTORY)
	@echo ""
	@echo "✅ All validation tests ran successfully!"
	@echo ""

debug: ## Show Makefile variables and verify paths
	@echo "=== Makefile Debug Info ==="
	@echo "MAKEFILE_DIR: $(MAKEFILE_DIR)"
	@echo "UV: $(UV)"
	@echo "ANSIBLE: $(ANSIBLE)"
	@echo ""
	@echo "=== Inventory Files ==="
	@echo "DC_INVENTORY: $(DC_INVENTORY)"
	@echo "SOMA_INVENTORY: $(SOMA_INVENTORY)"
	@echo "FD_INVENTORY: $(FD_INVENTORY)"
	@echo ""
	@echo "=== Playbooks ==="
	@echo "BUILD_PLAYBOOK: $(BUILD_PLAYBOOK)"
	@echo "DEPLOY_PLAYBOOK: $(DEPLOY_PLAYBOOK)"
	@echo ""
	@echo "=== File Existence Check ==="
	@test -f $(DC_INVENTORY) && echo "✓ DC inventory exists" || echo "✗ DC inventory NOT found"
	@test -f $(SOMA_INVENTORY) && echo "✓ SOMA inventory exists" || echo "✗ SOMA inventory NOT found"
	@test -f $(FD_INVENTORY) && echo "✓ FD inventory exists" || echo "✗ FD inventory NOT found"
	@test -f $(BUILD_PLAYBOOK) && echo "✓ Build playbook exists" || echo "✗ Build playbook NOT found"
	@test -f $(DEPLOY_PLAYBOOK) && echo "✓ Deploy playbook exists" || echo "✗ Deploy playbook NOT found"
	@echo ""
	@echo "=== Current Working Directory ==="
	@pwd
	@echo ""
	@echo "=== UV Version ==="
	@$(UV) --version

clean: ## Clean generated files
	@echo "Cleaning generated files..."
	@rm -rf $(MAKEFILE_DIR)intended/
	@echo "✓ Clean complete"
