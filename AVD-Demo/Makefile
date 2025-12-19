# Arista AVD/CloudVision Multi-Site Makefile
# Usage: make <action> <site>
# Example: make build ny5-ch3

.PHONY: help build deploy deploy-auto validate cleanup provision list-sites debug

# Variables
UV := uv
ANSIBLE := $(UV) run ansible-playbook
MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
SITES_DIR := $(MAKEFILE_DIR)sites
PLAYBOOKS_DIR := $(MAKEFILE_DIR)playbooks

# Available sites (automatically detected from sites directory)
AVAILABLE_SITES := $(notdir $(wildcard $(SITES_DIR)/*))

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Default target
.DEFAULT_GOAL := help

# Help target
help:
	@echo "$(GREEN)=========================================="
	@echo "AVD Multi-Site Demo - Available Commands"
	@echo "==========================================$(NC)"
	@echo ""
	@echo "$(YELLOW)Usage:$(NC)"
	@echo "  make <action> <site>       Execute action for specific site"
	@echo "  make <action>              Execute action for all sites"
	@echo ""
	@echo "$(YELLOW)Actions:$(NC)"
	@echo "  $(BLUE)build [site]$(NC)           Build AVD configurations"
	@echo "  $(BLUE)deploy [site]$(NC)          Deploy configs to CloudVision"
	@echo "  $(BLUE)deploy-auto [site]$(NC)     Deploy with auto-submit & change control"
	@echo "  $(BLUE)validate [site]$(NC)        Run ANTA validation tests"
	@echo "  $(BLUE)cleanup [site]$(NC)         Clean generated configs"
	@echo "  $(BLUE)all [site]$(NC)             Build + deploy-auto + validate"
	@echo ""
	@echo "$(YELLOW)Utilities:$(NC)"
	@echo "  $(BLUE)list-sites$(NC)             List available sites"
	@echo "  $(BLUE)debug$(NC)                  Show Makefile variables"
	@echo ""
	@echo "$(YELLOW)Available Sites:$(NC)"
	@for site in $(AVAILABLE_SITES); do \
		site_lower=$$(echo "$$site" | tr 'A-Z' 'a-z'); \
		echo "  • $$site_lower ($$site)"; \
	done
	@echo ""
	@echo "$(YELLOW)Examples:$(NC)"
	@echo "  make build ny5-ch3         Build configs for NY5-CH3 datacenter"
	@echo "  make deploy sf-soma        Deploy configs to SF-SOMA campus"
	@echo "  make validate sf-fd        Validate SF-FD campus"
	@echo "  make all ny5-ch3           Full workflow for NY5-CH3"
	@echo "  make build                 Build all sites"
	@echo ""

# List available sites
list-sites:
	@echo "$(GREEN)Available sites:$(NC)"
	@for site in $(AVAILABLE_SITES); do \
		site_lower=$$(echo "$$site" | tr 'A-Z' 'a-z'); \
		echo "  • $$site_lower ($$site)"; \
	done

# Build configurations
build:
	@echo "$(GREEN)=========================================="
	@echo "Building AVD Configurations"
	@echo "==========================================$(NC)"
	@echo ""
	@for site in $(AVAILABLE_SITES); do \
		echo "$(YELLOW)→ Building $$site...$(NC)"; \
		$(ANSIBLE) $(PLAYBOOKS_DIR)/build.yml -i $(SITES_DIR)/$$site/inventory.yml; \
		echo ""; \
	done
	@echo "$(GREEN)✅ All configurations built successfully!$(NC)"
	@echo ""

# Build specific site: make build <site>
build-%:
	@site_dir=$$(echo "$*" | tr 'A-Z' 'a-z'); \
	actual_site=""; \
	for dir in $(AVAILABLE_SITES); do \
		dir_lower=$$(echo "$$dir" | tr 'A-Z' 'a-z'); \
		if [ "$$dir_lower" = "$$site_dir" ]; then \
			actual_site=$$dir; \
			break; \
		fi; \
	done; \
	if [ -z "$$actual_site" ]; then \
		echo "$(RED)Error: Site '$*' not found$(NC)"; \
		echo "$(YELLOW)Available sites:$(NC)"; \
		$(MAKE) list-sites; \
		exit 1; \
	fi; \
	echo "$(GREEN)=========================================="; \
	echo "Building $$actual_site"; \
	echo "==========================================$(NC)"; \
	echo ""; \
	$(ANSIBLE) $(PLAYBOOKS_DIR)/build.yml -i $(SITES_DIR)/$$actual_site/inventory.yml; \
	echo ""; \
	echo "$(GREEN)✅ Build complete for $$actual_site$(NC)"; \
	echo ""

# Deploy configurations to CloudVision
deploy:
	@echo "$(GREEN)=========================================="
	@echo "Deploying to CloudVision"
	@echo "==========================================$(NC)"
	@echo ""
	@for site in $(AVAILABLE_SITES); do \
		echo "$(YELLOW)→ Deploying $$site...$(NC)"; \
		$(ANSIBLE) $(PLAYBOOKS_DIR)/deploy.yml -i $(SITES_DIR)/$$site/inventory.yml; \
		echo ""; \
	done
	@echo "$(GREEN)✅ All configurations deployed successfully!$(NC)"
	@echo ""

# Deploy specific site: make deploy <site>
deploy-%:
	@site_dir=$$(echo "$*" | tr 'A-Z' 'a-z'); \
	actual_site=""; \
	for dir in $(AVAILABLE_SITES); do \
		dir_lower=$$(echo "$$dir" | tr 'A-Z' 'a-z'); \
		if [ "$$dir_lower" = "$$site_dir" ]; then \
			actual_site=$$dir; \
			break; \
		fi; \
	done; \
	if [ -z "$$actual_site" ]; then \
		echo "$(RED)Error: Site '$*' not found$(NC)"; \
		echo "$(YELLOW)Available sites:$(NC)"; \
		$(MAKE) list-sites; \
		exit 1; \
	fi; \
	echo "$(GREEN)=========================================="; \
	echo "Deploying $$actual_site"; \
	echo "==========================================$(NC)"; \
	echo ""; \
	$(ANSIBLE) $(PLAYBOOKS_DIR)/deploy.yml -i $(SITES_DIR)/$$actual_site/inventory.yml; \
	echo ""; \
	echo "$(GREEN)✅ Deploy complete for $$actual_site$(NC)"; \
	echo ""

# Deploy with auto-submit and change control
deploy-auto:
	@echo "$(GREEN)=========================================="
	@echo "Deploying to CloudVision (Auto Mode)"
	@echo "==========================================$(NC)"
	@echo ""
	@for site in $(AVAILABLE_SITES); do \
		echo "$(YELLOW)→ Deploying $$site...$(NC)"; \
		$(ANSIBLE) $(PLAYBOOKS_DIR)/deploy_auto.yml -i $(SITES_DIR)/$$site/inventory.yml; \
		echo ""; \
	done
	@echo "$(GREEN)✅ All configurations deployed successfully!$(NC)"
	@echo ""

# Deploy-auto specific site: make deploy-auto <site>
deploy-auto-%:
	@site_dir=$$(echo "$*" | tr 'A-Z' 'a-z'); \
	actual_site=""; \
	for dir in $(AVAILABLE_SITES); do \
		dir_lower=$$(echo "$$dir" | tr 'A-Z' 'a-z'); \
		if [ "$$dir_lower" = "$$site_dir" ]; then \
			actual_site=$$dir; \
			break; \
		fi; \
	done; \
	if [ -z "$$actual_site" ]; then \
		echo "$(RED)Error: Site '$*' not found$(NC)"; \
		echo "$(YELLOW)Available sites:$(NC)"; \
		$(MAKE) list-sites; \
		exit 1; \
	fi; \
	echo "$(GREEN)=========================================="; \
	echo "Deploying $$actual_site (Auto Mode)"; \
	echo "==========================================$(NC)"; \
	echo ""; \
	$(ANSIBLE) $(PLAYBOOKS_DIR)/deploy_auto.yml -i $(SITES_DIR)/$$actual_site/inventory.yml; \
	echo ""; \
	echo "$(GREEN)✅ Deploy complete for $$actual_site$(NC)"; \
	echo ""

# Validate device state with ANTA
validate:
	@echo "$(GREEN)=========================================="
	@echo "Running ANTA validation tests"
	@echo "==========================================$(NC)"
	@echo ""
	@for site in $(AVAILABLE_SITES); do \
		echo "$(YELLOW)→ Validating $$site...$(NC)"; \
		$(ANSIBLE) $(PLAYBOOKS_DIR)/validate.yml -i $(SITES_DIR)/$$site/inventory.yml; \
		echo ""; \
	done
	@echo "$(GREEN)✅ All validation tests ran successfully!$(NC)"
	@echo ""

# Validate specific site: make validate <site>
validate-%:
	@site_dir=$$(echo "$*" | tr 'A-Z' 'a-z'); \
	actual_site=""; \
	for dir in $(AVAILABLE_SITES); do \
		dir_lower=$$(echo "$$dir" | tr 'A-Z' 'a-z'); \
		if [ "$$dir_lower" = "$$site_dir" ]; then \
			actual_site=$$dir; \
			break; \
		fi; \
	done; \
	if [ -z "$$actual_site" ]; then \
		echo "$(RED)Error: Site '$*' not found$(NC)"; \
		echo "$(YELLOW)Available sites:$(NC)"; \
		$(MAKE) list-sites; \
		exit 1; \
	fi; \
	echo "$(GREEN)=========================================="; \
	echo "Running ANTA validation for $$actual_site"; \
	echo "==========================================$(NC)"; \
	echo ""; \
	export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES && \
	$(ANSIBLE) $(PLAYBOOKS_DIR)/validate.yml -i $(SITES_DIR)/$$actual_site/inventory.yml; \
	echo ""; \
	echo "$(GREEN)✅ Validation complete for $$actual_site$(NC)"; \
	echo ""

# Clean generated files
cleanup:
	@echo "$(YELLOW)Cleaning generated files for all sites...$(NC)"
	@rm -rf $(MAKEFILE_DIR)intended/
	@rm -rf $(MAKEFILE_DIR)documentation/
	@rm -rf $(MAKEFILE_DIR)reports/
	@echo "$(GREEN)✓ Clean complete$(NC)"

# Cleanup specific site: make cleanup <site>
cleanup-%:
	@site_dir=$$(echo "$*" | tr 'A-Z' 'a-z'); \
	actual_site=""; \
	for dir in $(AVAILABLE_SITES); do \
		dir_lower=$$(echo "$$dir" | tr 'A-Z' 'a-z'); \
		if [ "$$dir_lower" = "$$site_dir" ]; then \
			actual_site=$$dir; \
			break; \
		fi; \
	done; \
	if [ -z "$$actual_site" ]; then \
		echo "$(RED)Error: Site '$*' not found$(NC)"; \
		echo "$(YELLOW)Available sites:$(NC)"; \
		$(MAKE) list-sites; \
		exit 1; \
	fi; \
	echo "$(YELLOW)Cleaning generated files for $$actual_site...$(NC)"; \
	find $(MAKEFILE_DIR)intended/ -name "*$$actual_site*" -type f -delete 2>/dev/null || true; \
	find $(MAKEFILE_DIR)reports/ -name "*$$actual_site*" -type d -exec rm -rf {} + 2>/dev/null || true; \
	echo "$(GREEN)✓ Clean complete for $$actual_site$(NC)"

# Full workflow for all sites: build + deploy-auto + validate
provision:
	@echo "$(GREEN)=========================================="
	@echo "Running full workflow for all sites"
	@echo "==========================================$(NC)"
	@echo ""
	@$(MAKE) build
	@$(MAKE) deploy-auto
	@$(MAKE) validate
	@echo "$(GREEN)✅ Full workflow complete for all sites!$(NC)"
	@echo ""

# Full workflow for specific site: make all <site>
provision-%:
	@site_dir=$$(echo "$*" | tr 'A-Z' 'a-z'); \
	actual_site=""; \
	for dir in $(AVAILABLE_SITES); do \
		dir_lower=$$(echo "$$dir" | tr 'A-Z' 'a-z'); \
		if [ "$$dir_lower" = "$$site_dir" ]; then \
			actual_site=$$dir; \
			break; \
		fi; \
	done; \
	if [ -z "$$actual_site" ]; then \
		echo "$(RED)Error: Site '$*' not found$(NC)"; \
		echo "$(YELLOW)Available sites:$(NC)"; \
		$(MAKE) list-sites; \
		exit 1; \
	fi; \
	echo "$(GREEN)=========================================="; \
	echo "Running full workflow for $$actual_site"; \
	echo "==========================================$(NC)"; \
	echo ""; \
	site_lower=$$(echo "$$actual_site" | tr 'A-Z' 'a-z'); \
	$(MAKE) build-$$site_lower; \
	$(MAKE) deploy-auto-$$site_lower; \
	$(MAKE) validate-$$site_lower; \
	echo "$(GREEN)✅ Full workflow complete for $$actual_site!$(NC)"; \
	echo ""

# Debug target
debug:
	@echo "$(BLUE)=== Makefile Debug Info ===$(NC)"
	@echo "MAKEFILE_DIR: $(MAKEFILE_DIR)"
	@echo "UV: $(UV)"
	@echo "ANSIBLE: $(ANSIBLE)"
	@echo ""
	@echo "$(BLUE)=== Directories ===$(NC)"
	@echo "SITES_DIR: $(SITES_DIR)"
	@echo "PLAYBOOKS_DIR: $(PLAYBOOKS_DIR)"
	@echo ""
	@echo "$(BLUE)=== Available Sites ===$(NC)"
	@for site in $(AVAILABLE_SITES); do \
		echo "  • $$site"; \
	done
	@echo ""
	@echo "$(BLUE)=== File Existence Check ===$(NC)"
	@for site in $(AVAILABLE_SITES); do \
		if [ -f "$(SITES_DIR)/$$site/inventory.yml" ]; then \
			echo "$(GREEN)✓$(NC) $$site inventory exists"; \
		else \
			echo "$(RED)✗$(NC) $$site inventory NOT found"; \
		fi \
	done
	@echo ""
	@test -f $(PLAYBOOKS_DIR)/build.yml && echo "$(GREEN)✓$(NC) Build playbook exists" || echo "$(RED)✗$(NC) Build playbook NOT found"
	@test -f $(PLAYBOOKS_DIR)/deploy.yml && echo "$(GREEN)✓$(NC) Deploy playbook exists" || echo "$(RED)✗$(NC) Deploy playbook NOT found"
	@test -f $(PLAYBOOKS_DIR)/deploy_auto.yml && echo "$(GREEN)✓$(NC) Deploy-auto playbook exists" || echo "$(RED)✗$(NC) Deploy-auto playbook NOT found"
	@test -f $(PLAYBOOKS_DIR)/validate.yml && echo "$(GREEN)✓$(NC) Validate playbook exists" || echo "$(RED)✗$(NC) Validate playbook NOT found"
	@echo ""
	@echo "$(BLUE)=== Current Working Directory ===$(NC)"
	@pwd
	@echo ""
	@echo "$(BLUE)=== UV Version ===$(NC)"
	@$(UV) --version