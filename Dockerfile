# Dockerfile for building Enchantment Indicator Mod
# This provides a containerized build environment that doesn't require
# Windows or Skyrim tools to be installed locally

FROM mcr.microsoft.com/windows/servercore:ltsc2022

LABEL maintainer="Skyrim Modding Community"
LABEL description="Build environment for Enchantment Indicator Mod"

# Install PowerShell
RUN powershell -Command \
    $ProgressPreference = 'SilentlyContinue'; \
    Invoke-WebRequest -Uri https://github.com/PowerShell/PowerShell/releases/download/v7.4.0/PowerShell-7.4.0-win-x64.msi \
    -OutFile PowerShell-7.4.0-win-x64.msi; \
    msiexec /i PowerShell-7.4.0-win-x64.msi /quiet; \
    Remove-Item PowerShell-7.4.0-win-x64.msi -Force

# Set working directory
WORKDIR /build

# Copy project files
COPY . .

# Create output directory
RUN mkdir build_output

# Run build script
CMD ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "build.ps1"]
