#Requires -Version 5.1
<#
.SYNOPSIS
    Builds the Enchantment Indicator Mod for Skyrim LE
    
.DESCRIPTION
    Compiles Papyrus scripts, ActionScript UI components, and optionally the SKSE plugin
    
.EXAMPLE
    .\build.ps1
    
.PARAMETER SkipActionScript
    Skip ActionScript compilation (faster builds)
    
.PARAMETER SkipSKSE
    Skip SKSE plugin build
    
.PARAMETER Clean
    Clean build output before starting
#>

param(
    [switch]$SkipActionScript,
    [switch]$SkipSKSE,
    [switch]$Clean
)

# Import configuration
. ".\build.config.ps1"

# ============================================================================
# Helper Functions
# ============================================================================

function Write-Status {
    param([string]$Message, [string]$Type = "Info")
    
    $color = @{
        "Success" = "Green"
        "Error"   = "Red"
        "Warning" = "Yellow"
        "Info"    = "Cyan"
    }[$Type]
    
    $prefix = @{
        "Success" = "[OK]"
        "Error"   = "[ERR]"
        "Warning" = "[WARN]"
        "Info"    = "[INFO]"
    }[$Type]
    
    Write-Host "$prefix $Message" -ForegroundColor $color
}

function Test-ToolExists {
    param([string]$ToolPath, [string]$ToolName)
    
    if (-not (Test-Path $ToolPath)) {
        Write-Status "$ToolName not found at: $ToolPath" "Warning"
        return $false
    }
    
    Write-Status "Found $ToolName" "Success"
    return $true
}

function Invoke-Compilation {
    param(
        [string]$SourceFile,
        [string]$OutputDir,
        [string]$Compiler,
        [string[]]$CompilerArgs
    )
    
    $sourceFileName = Split-Path $SourceFile -Leaf
    
    try {
        & $Compiler @CompilerArgs $SourceFile -o=$OutputDir | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Status "Compiled: $sourceFileName" "Success"
            return $true
        } else {
            Write-Status "Failed to compile: $sourceFileName" "Error"
            return $false
        }
    }
    catch {
        Write-Status "Error compiling $sourceFileName : $_" "Error"
        return $false
    }
}

# ============================================================================
# Main Build Process
# ============================================================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Enchantment Indicator Mod - Build Script" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Print configuration
Write-Status "Build Configuration:" "Info"
Write-Host "  Skyrim Path: $skyrimPath"
Write-Host "  Creation Kit: $ckPath"
Write-Host "  Output Directory: $modOutput"
Write-Host ""

# ===== Setup =====
if ($Clean) {
    Write-Status "Cleaning old builds..." "Info"
    if (Test-Path $buildOutput) {
        Remove-Item $buildOutput -Recurse -Force | Out-Null
    }
}

Write-Status "Creating output directories..." "Info"
@(
    $modOutput,
    (Join-Path $modOutput "Scripts"),
    (Join-Path $modOutput "UI"),
    (Join-Path $modOutput "SKSE\Plugins")
) | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -ItemType Directory -Path $_ | Out-Null
    }
}
Write-Status "Output directories created" "Success"
Write-Host ""

# ===== Step 1: Compile Papyrus Scripts =====
Write-Host "===== STEP 1: Compile Papyrus Scripts =====" -ForegroundColor Yellow
Write-Host ""

if (-not (Test-ToolExists $papyrusCompiler "Papyrus Compiler")) {
    Write-Status "Papyrus Compiler not found. Skipping Papyrus compilation." "Error"
    Write-Status "Ensure Creation Kit is installed at: $ckPath" "Warning"
    $skipPapyrus = $true
} else {
    $skipPapyrus = $false
    
    $scriptsOutput = Join-Path $modOutput "Scripts"
    $compiledCount = 0
    
    foreach ($scriptSource in $scriptSources) {
        if (Test-Path $scriptSource) {
            if (Invoke-Compilation -SourceFile $scriptSource -OutputDir $scriptsOutput -Compiler $papyrusCompiler -CompilerArgs @("-f=$papyrusFlags")) {
                $compiledCount++
            }
        } else {
            Write-Status "Source file not found: $scriptSource" "Warning"
        }
    }
    
    Write-Host ""
    Write-Status "Compiled $compiledCount/$($scriptSources.Count) Papyrus scripts" "Info"
}

# ===== Step 2: Compile ActionScript =====
Write-Host ""
Write-Host "===== STEP 2: Compile ActionScript =====" -ForegroundColor Yellow
Write-Host ""

if ($SkipActionScript) {
    Write-Status "Skipping ActionScript compilation (--SkipActionScript)" "Info"
} else {
    $asCompiler = $null
    $asCompilerName = "Unknown"
    
    if (Test-ToolExists $mtxcPath "mtxc") {
        $asCompiler = $mtxcPath
        $asCompilerName = "mtxc"
    } elseif (Test-Path "$flexSdkPath\bin\mxmlc.exe") {
        $asCompiler = "$flexSdkPath\bin\mxmlc.exe"
        $asCompilerName = "Flex SDK mxmlc"
    }
    
    if ($asCompiler) {
        Write-Status "Using $asCompilerName for ActionScript compilation" "Info"
        
        $uiOutput = Join-Path $modOutput "UI"
        $compiledCount = 0
        
        foreach ($asSource in $actionScriptSources) {
            if (Test-Path $asSource) {
                $outputFile = Join-Path $uiOutput ([IO.Path]::GetFileNameWithoutExtension($asSource) + ".swf")
                
                $args = @("-version", "10.0", "-output", $outputFile)
                if (Invoke-Compilation -SourceFile $asSource -OutputDir $uiOutput -Compiler $asCompiler -CompilerArgs $args) {
                    $compiledCount++
                }
            }
        }
        
        Write-Host ""
        Write-Status "Compiled $compiledCount/$($actionScriptSources.Count) ActionScript files" "Info"
    } else {
        Write-Status "No ActionScript compiler found (mtxc or Flex SDK)" "Warning"
        Write-Status "Skipping ActionScript compilation" "Info"
        Write-Status "You can manually compile .as files later" "Info"
    }
}

# ===== Step 3: Build SKSE Plugin =====
Write-Host ""
Write-Host "===== STEP 3: Build SKSE Plugin =====" -ForegroundColor Yellow
Write-Host ""

if ($SkipSKSE) {
    Write-Status "Skipping SKSE plugin build (--SkipSKSE)" "Info"
} else {
    if (Test-ToolExists $msbuildPath "MSBuild") {
        Write-Status "SKSE plugin build requires Visual Studio project setup" "Info"
        Write-Status "See docs/SKSE_BUILD_GUIDE.md for compilation instructions" "Info"
    } else {
        Write-Status "Visual Studio not found" "Warning"
        Write-Status "See docs/SKSE_BUILD_GUIDE.md for manual compilation instructions" "Info"
    }
}

# ===== Step 4: Copy Supporting Files =====
Write-Host ""
Write-Host "===== STEP 4: Copy Supporting Files =====" -ForegroundColor Yellow
Write-Host ""

Write-Status "Copying documentation..." "Info"
Copy-Item "docs\*.md" $modOutput -Force -ErrorAction SilentlyContinue | Out-Null
Write-Status "Documentation copied" "Success"

# Create INFO file
$infoFile = Join-Path $modOutput "INFO.txt"
@"
Plugin Name: Enchantment Indicator
Plugin Version: $modVersion
Description: Displays [K] indicators next to enchanted items if the player has learned the enchantment
Dependencies: SKSE 1.7.3+ (optional), SkyUI 4.1+ (optional)
Build Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
"@ | Set-Content $infoFile
Write-Status "Created INFO.txt" "Success"

# Create README
$readmeFile = Join-Path $modOutput "README.txt"
@"
Enchantment Indicator Mod for Skyrim LE

INSTALLATION:
1. Copy this entire folder to Skyrim\Data\
2. Activate EnchantmentIndicator.esp in your mod launcher
3. Ensure SKSE is installed (optional but recommended)

FEATURES:
- Displays [K] indicator next to known enchantments
- Works in inventory, barter, and container menus
- Customizable colors and indicator text
- Compatible with SkyUI

TROUBLESHOOTING:
See docs/COMPLETE_GUIDE.md for full troubleshooting guide

For more information, see the included documentation files.
"@ | Set-Content $readmeFile
Write-Status "Created README.txt" "Success"

# ===== Build Summary =====
Write-Host ""
Write-Host "===== BUILD SUMMARY =====" -ForegroundColor Green
Write-Host ""
Write-Status "Build completed successfully!" "Success"
Write-Host ""
Write-Host "Output Location: $modOutput" -ForegroundColor Green
Write-Host ""
Write-Host "Contents:"
Write-Host "  - Scripts\*.pex (Compiled Papyrus scripts)"
Write-Host "  - UI\*.swf (Compiled ActionScript components)"
Write-Host "  - Documentation files"
Write-Host "  - README.txt and INFO.txt"
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Review compiled files in: $modOutput"
Write-Host "  2. Create .esp file in Creation Kit (see docs/QUICKSTART.md)"
Write-Host "  3. Test in Skyrim LE"
Write-Host "  4. Package and distribute"
Write-Host ""

# Open build output in Explorer (optional)
if ((Read-Host "Open build output folder? (y/n)") -eq 'y') {
    Invoke-Item $modOutput
}
