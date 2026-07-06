# Dockerfile for building Enchantment Indicator Mod
# Linux-based build environment for cross-platform compilation

FROM ubuntu:22.04

LABEL maintainer="Skyrim Modding Community"
LABEL description="Build environment for Enchantment Indicator Mod"

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    wget \
    ca-certificates \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /build

# Copy project files
COPY . .

# Create output directory
RUN mkdir -p build_output

# Run build script with Linux mode
CMD ["bash", "build.sh", "--linux"]
