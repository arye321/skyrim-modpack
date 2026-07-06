#!/bin/bash
# build.sh - Build script for Unix-like systems (Linux, macOS)
# This script provides a Unix-friendly interface to the build system
# Note: Requires access to Windows build tools or Docker

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
MOD_NAME="EnchantmentIndicator"
MOD_VERSION="1.0.0"
BUILD_DIR="build_output"
MOD_OUTPUT="$BUILD_DIR/${MOD_NAME}_v${MOD_VERSION}"

# Helper functions
print_header() {
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${CYAN}[*]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Check for required tools
check_tools() {
    print_header "Checking for required tools"
    
    local needs_docker=false
    
    if command -v docker &> /dev/null; then
        print_success "Docker found"
    else
        print_warning "Docker not found (needed for cross-platform builds)"
        needs_docker=true
    fi
    
    if command -v make &> /dev/null; then
        print_success "Make found"
    else
        print_warning "Make not found"
    fi
    
    if command -v pwsh &> /dev/null; then
        print_success "PowerShell found (can run Windows build scripts)"
    else
        print_info "PowerShell not found (only Docker builds available)"
    fi
    
    echo ""
}

# Validate source files
validate_sources() {
    print_header "Validating source files"
    
    local psc_count=$(find source/scripts -name "*.psc" 2>/dev/null | wc -l)
    local as_count=$(find source/ui -name "*.as" 2>/dev/null | wc -l)
    local cpp_count=$(find source/skse -name "*.cpp" 2>/dev/null | wc -l)
    
    echo "Papyrus scripts: $psc_count files"
    find source/scripts -name "*.psc" -exec echo "  - {}" \;
    
    echo ""
    echo "ActionScript files: $as_count files"
    find source/ui -name "*.as" -exec echo "  - {}" \;
    
    echo ""
    echo "SKSE source: $cpp_count files"
    find source/skse -name "*.cpp" -exec echo "  - {}" \;
    
    if [ $psc_count -gt 0 ] && [ $as_count -gt 0 ] && [ $cpp_count -gt 0 ]; then
        print_success "All source files found"
    else
        print_error "Some source files missing"
        return 1
    fi
    
    echo ""
}

# Build using Docker
build_docker() {
    print_header "Building with Docker"
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker not found. Please install Docker."
        return 1
    fi
    
    print_info "Building Docker image..."
    docker build -t "enchantment-indicator:latest" .
    
    print_info "Running build in container..."
    mkdir -p build_output
    
    docker run --rm \
        -v "$(pwd)/build_output:/build/build_output" \
        -v "$(pwd)/source:/build/source" \
        -v "$(pwd)/docs:/build/docs" \
        "enchantment-indicator:latest"
    
    print_success "Build complete"
    print_info "Output: $BUILD_DIR/"
    echo ""
}

# Build using PowerShell (WSL or native Windows)
build_powershell() {
    print_header "Building with PowerShell"
    
    if ! command -v pwsh &> /dev/null; then
        print_error "PowerShell not found"
        print_info "Install PowerShell from: https://github.com/PowerShell/PowerShell"
        return 1
    fi
    
    print_info "Running build script..."
    pwsh -NoProfile -ExecutionPolicy Bypass -File ./build.ps1
    
    echo ""
}

# Build using Linux (validates and stages source files)
build_linux() {
    print_header "Building on Linux"
    
    print_info "Validating source files..."
    validate_sources || return 1
    
    print_info "Staging source files..."
    mkdir -p "$MOD_OUTPUT/Scripts"
    mkdir -p "$MOD_OUTPUT/UI"
    mkdir -p "$MOD_OUTPUT/SKSE/Plugins"
    
    # Copy Papyrus source scripts
    cp source/scripts/*.psc "$MOD_OUTPUT/Scripts/" 2>/dev/null || true
    
    # Copy ActionScript source files
    cp source/ui/skyui_custom/*.as "$MOD_OUTPUT/UI/" 2>/dev/null || true
    
    # Copy SKSE source
    cp source/skse/*.cpp "$MOD_OUTPUT/SKSE/" 2>/dev/null || true
    
    print_success "Source files staged"
    print_info "Note: Full compilation (Papyrus → .pex, ActionScript → .swf) requires Windows/PowerShell or macOS"
    print_info "For real compilation, run on Windows: .\\build.ps1 or .\\build.bat"
    
    echo ""
}

# Create output structure
setup_output() {
    print_header "Setting up output directories"
    
    mkdir -p "$MOD_OUTPUT/Scripts"
    mkdir -p "$MOD_OUTPUT/UI"
    mkdir -p "$MOD_OUTPUT/SKSE/Plugins"
    mkdir -p "$MOD_OUTPUT/Docs"
    
    print_success "Output directories created"
    
    # Copy documentation
    cp docs/*.md "$MOD_OUTPUT/Docs/" 2>/dev/null || true
    cp README.md "$MOD_OUTPUT/" 2>/dev/null || true
    
    # Create manifest
    {
        echo "Name: $MOD_NAME"
        echo "Version: $MOD_VERSION"
        echo "Build Date: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Platform: $(uname -s)"
    } > "$MOD_OUTPUT/MANIFEST.txt"
    
    # Create README
    {
        echo "Enchantment Indicator Mod for Skyrim LE"
        echo ""
        echo "INSTALLATION:"
        echo "1. Copy to Skyrim\\Data\\"
        echo "2. Activate ESP in mod launcher"
        echo ""
        echo "See docs/ for full guides"
    } > "$MOD_OUTPUT/README.txt"
    
    print_success "Setup complete"
    echo ""
}

# Show usage
usage() {
    cat << EOF
Enchantment Indicator Mod - Build Script

Usage: $0 [OPTIONS]

Options:
    -h, --help           Show this help message
    -c, --check          Check tools and validate sources
    -d, --docker         Build using Docker
    -p, --powershell     Build using PowerShell (Windows/WSL)
    -l, --linux          Build on Linux (source staging only)
    -v, --validate       Validate source files only
    -c, --clean          Clean build output
    -i, --info           Show project information

Examples:
    $0 --docker          # Build with Docker (cross-platform)
    $0 --powershell      # Build with PowerShell
    $0 --check           # Check environment
    $0 --clean           # Clean output

For full build documentation, see: BUILD.md
EOF
}

# Parse arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                usage
                exit 0
                ;;
            -c|--check)
                check_tools
                validate_sources
                exit 0
                ;;
            -d|--docker)
                validate_sources || exit 1
                build_docker
                setup_output
                exit $?
                ;;
            -p|--powershell)
                validate_sources || exit 1
                build_powershell
                setup_output
                exit $?
                ;;
            -l|--linux)
                build_linux
                setup_output
                exit $?
                ;;
            -v|--validate)
                validate_sources
                exit $?
                ;;
            -c|--clean)
                print_header "Cleaning build output"
                rm -rf "$BUILD_DIR"
                print_success "Clean complete"
                exit 0
                ;;
            -i|--info)
                print_header "Project Information"
                echo "Name: $MOD_NAME"
                echo "Version: $MOD_VERSION"
                echo "Build Directory: $BUILD_DIR"
                echo ""
                echo "Source files: $(find source -type f \( -name "*.psc" -o -name "*.as" -o -name "*.cpp" \) | wc -l)"
                echo "Documentation: $(find docs -name "*.md" | wc -l)"
                echo ""
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                echo ""
                usage
                exit 1
                ;;
        esac
        shift
    done
}

# Main
main() {
    if [ $# -eq 0 ]; then
        print_header "Enchantment Indicator Mod - Build"
        echo ""
        print_info "No arguments provided. Available options:"
        echo ""
        echo "  --docker       Build using Docker (recommended)"
        echo "  --powershell   Build using PowerShell"
        echo "  --check        Check tools and validate"
        echo "  --validate     Validate source files"
        echo "  --clean        Clean build output"
        echo "  --info         Show project information"
        echo ""
        echo "Run '$0 --help' for more information"
        echo ""
        
        # Auto-detect best build method
        print_info "Attempting to detect best build method..."
        echo ""
        
        if command -v docker &> /dev/null; then
            print_info "Docker detected - using Docker build"
            parse_args --docker
        elif command -v pwsh &> /dev/null; then
            print_info "PowerShell detected - using PowerShell build"
            parse_args --powershell
        else
            print_info "Using Linux build (source staging mode)"
            parse_args --linux
        fi
    else
        parse_args "$@"
    fi
}

# Run
main "$@"
