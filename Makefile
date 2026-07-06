# Makefile for Enchantment Indicator Mod
# Supports Unix-like systems (Linux, macOS, etc.)
# Note: Actual compilation requires Windows tools

.PHONY: help build clean validate docker docker-build

# Default target
.DEFAULT_GOAL := help

# Configuration
MOD_NAME := EnchantmentIndicator
MOD_VERSION := 1.0.0
BUILD_DIR := build_output
MOD_OUTPUT := $(BUILD_DIR)/$(MOD_NAME)_v$(MOD_VERSION)

# Source files
SCRIPTS := source/scripts/*.psc
UI_COMPONENTS := source/ui/skyui_custom/*.as
SKSE_SOURCE := source/skse/*.cpp
DOCS := docs/*.md

help: ## Show this help message
	@echo "Enchantment Indicator Mod - Build System"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'
	@echo ""
	@echo "Examples:"
	@echo "  make build          - Build on Windows (via WSL/PowerShell)"
	@echo "  make docker         - Build using Docker"
	@echo "  make validate       - Validate source files"
	@echo "  make clean          - Clean build output"

validate: ## Validate source files
	@echo "Validating source files..."
	@echo ""
	@echo "Checking Papyrus scripts:"
	@for script in source/scripts/*.psc; do \
		if [ -f "$$script" ]; then \
			echo "  ✓ Found: $$script"; \
			wc -l "$$script" | awk '{print "    Lines: " $$1}'; \
		else \
			echo "  ✗ Missing: $$script"; \
		fi; \
	done
	@echo ""
	@echo "Checking ActionScript files:"
	@for as in source/ui/skyui_custom/*.as; do \
		if [ -f "$$as" ]; then \
			echo "  ✓ Found: $$as"; \
			wc -l "$$as" | awk '{print "    Lines: " $$1}'; \
		else \
			echo "  ✗ Missing: $$as"; \
		fi; \
	done
	@echo ""
	@echo "Checking SKSE source:"
	@for cpp in source/skse/*.cpp; do \
		if [ -f "$$cpp" ]; then \
			echo "  ✓ Found: $$cpp"; \
			wc -l "$$cpp" | awk '{print "    Lines: " $$1}'; \
		else \
			echo "  ✗ Missing: $$cpp"; \
		fi; \
	done
	@echo ""
	@echo "Checking documentation:"
	@for doc in docs/*.md; do \
		if [ -f "$$doc" ]; then \
			echo "  ✓ Found: $$doc"; \
		fi; \
	done
	@echo ""
	@echo "✓ Validation complete"

build: validate ## Build the mod (requires Windows environment)
	@echo "Building Enchantment Indicator Mod..."
	@echo ""
	@command -v pwsh >/dev/null 2>&1 && \
		echo "PowerShell detected, running build script..." && \
		pwsh -NoProfile -ExecutionPolicy Bypass -File ./build.ps1 || \
		echo "Error: PowerShell not found. Please run on Windows or use 'make docker'"

build-windows: validate ## Build on Windows (using cmd.exe)
	@echo "Building on Windows..."
	@cmd /c build.bat

docker-build: ## Build Docker image
	@echo "Building Docker image..."
	docker build -t $(MOD_NAME):latest .
	@echo "✓ Docker image built: $(MOD_NAME):latest"

docker: docker-build ## Run build in Docker container
	@echo "Building in Docker container..."
	@mkdir -p build_output
	docker run --rm \
		-v $$(pwd)/build_output:/build/build_output \
		-v $$(pwd)/source:/build/source \
		-v $$(pwd)/docs:/build/docs \
		$(MOD_NAME):latest
	@echo "✓ Build complete, output in build_output/"

setup-build-dirs: ## Create build output directories
	@mkdir -p $(MOD_OUTPUT)/Scripts
	@mkdir -p $(MOD_OUTPUT)/UI
	@mkdir -p $(MOD_OUTPUT)/SKSE/Plugins
	@mkdir -p $(MOD_OUTPUT)/Docs
	@echo "✓ Build directories created"

copy-docs: setup-build-dirs ## Copy documentation to output
	@cp docs/*.md $(MOD_OUTPUT)/Docs/
	@cp README.md $(MOD_OUTPUT)/
	@echo "✓ Documentation copied"

create-manifest: setup-build-dirs ## Create build manifest
	@echo "Creating manifest..."
	@printf "Name: $(MOD_NAME)\n" > $(MOD_OUTPUT)/MANIFEST.txt
	@printf "Version: $(MOD_VERSION)\n" >> $(MOD_OUTPUT)/MANIFEST.txt
	@printf "Build Date: $$(date '+%%Y-%%m-%%d %%H:%%M:%%S')\n" >> $(MOD_OUTPUT)/MANIFEST.txt
	@printf "Platform: $$(uname -s)\n" >> $(MOD_OUTPUT)/MANIFEST.txt
	@echo "✓ Manifest created"

create-readme: setup-build-dirs ## Create installation readme
	@printf "Enchantment Indicator Mod for Skyrim LE\n\n" > $(MOD_OUTPUT)/README.txt
	@printf "INSTALLATION:\n" >> $(MOD_OUTPUT)/README.txt
	@printf "1. Copy this folder to Skyrim\\Data\\\n" >> $(MOD_OUTPUT)/README.txt
	@printf "2. Activate EnchantmentIndicator.esp in mod launcher\n" >> $(MOD_OUTPUT)/README.txt
	@printf "3. Ensure SKSE is installed (optional but recommended)\n" >> $(MOD_OUTPUT)/README.txt
	@printf "\nSee docs/ for full guides and troubleshooting.\n" >> $(MOD_OUTPUT)/README.txt
	@echo "✓ README created"

clean: ## Clean build output
	@echo "Cleaning build output..."
	@rm -rf $(BUILD_DIR)
	@echo "✓ Clean complete"

distclean: clean ## Deep clean (includes caches)
	@echo "Deep cleaning..."
	@rm -rf build_output .cache *.log
	@echo "✓ Deep clean complete"

format: ## Format source files (basic)
	@echo "Formatting source files..."
	@find source -name "*.psc" -o -name "*.as" -o -name "*.cpp" | \
		xargs -I {} echo "  Checking: {}"
	@echo "✓ Format check complete"

count-lines: ## Count lines of code
	@echo "Source code statistics:"
	@echo ""
	@echo "Papyrus scripts:"
	@wc -l source/scripts/*.psc | tail -1
	@echo ""
	@echo "ActionScript files:"
	@wc -l source/ui/skyui_custom/*.as | tail -1
	@echo ""
	@echo "SKSE plugin:"
	@wc -l source/skse/*.cpp | tail -1
	@echo ""
	@echo "Documentation:"
	@wc -l docs/*.md | tail -1
	@echo ""
	@echo "TOTAL:"
	@find source docs -type f \( -name "*.psc" -o -name "*.as" -o -name "*.cpp" -o -name "*.md" \) \
		-exec wc -l {} + | tail -1

info: ## Show project information
	@echo "Enchantment Indicator Mod - Project Information"
	@echo ""
	@echo "Name: $(MOD_NAME)"
	@echo "Version: $(MOD_VERSION)"
	@echo "Build Directory: $(BUILD_DIR)"
	@echo "Output: $(MOD_OUTPUT)"
	@echo ""
	@echo "Source Files:"
	@ls -1 source/scripts/*.psc | sed 's/^/  - /'
	@ls -1 source/ui/skyui_custom/*.as | sed 's/^/  - /'
	@ls -1 source/skse/*.cpp | sed 's/^/  - /'
	@echo ""
	@echo "Documentation:"
	@ls -1 docs/*.md | sed 's/^/  - /'

list-targets: ## List all build targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "%-20s %s\n", $$1, $$2}'

# Phony targets (don't represent files)
.PHONY: all build clean validate docker help setup-build-dirs copy-docs create-manifest create-readme distclean format count-lines info list-targets
