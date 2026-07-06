# Build System Documentation

## Overview

This project includes multiple build systems to compile the Enchantment Indicator Mod for Skyrim LE:

- **Windows Batch** (`build.bat`) - Classic batch script
- **PowerShell** (`build.ps1`) - Modern Windows scripting
- **GitHub Actions** (`.github/workflows/build.yml`) - CI/CD automation
- **Docker** (`Dockerfile`) - Cross-platform containerized build

Choose the method that works best for your setup.

---

## Quick Start

### Option 1: Windows PowerShell (Recommended)

**Prerequisites:**
- Windows 10/11
- PowerShell 5.1+
- Skyrim LE installed at: `C:\Program Files (x86)\Steam\steamapps\common\Skyrim`
- Creation Kit installed

**Run:**
```powershell
# From project root
.\build.ps1

# Or with options:
.\build.ps1 -SkipActionScript    # Skip AS compilation for faster builds
.\build.ps1 -SkipSKSE             # Skip SKSE plugin build
.\build.ps1 -Clean                # Clean old builds first
```

**Output:** `build_output\EnchantmentIndicator_v1.0\`

---

### Option 2: Windows Batch

**Prerequisites:**
- Windows 10/11
- Skyrim LE installed
- Creation Kit installed

**Run:**
```batch
cd /d C:\path\to\project
build.bat
```

**Output:** `build_output\EnchantmentIndicator_v1.0\`

---

### Option 3: GitHub Actions (Automated)

**Setup:**
1. Push code to GitHub repository
2. GitHub Actions automatically runs on push/PR
3. Download compiled artifacts from Actions tab

**Features:**
- Automatic validation
- Parallel builds
- Artifact storage
- Release creation

**View:** https://github.com/YOUR_USERNAME/skyrim-modpack/actions

---

### Option 4: Docker (Linux/Mac)

**Prerequisites:**
- Docker installed
- No Skyrim tools needed (containerized)

**Run:**
```bash
docker build -t enchantment-indicator .
docker run -v $(pwd)/build_output:/build enchantment-indicator
```

**Output:** `build_output/EnchantmentIndicator_v1.0/`

---

## Build Configuration

Edit `build.config.ps1` to customize paths:

```powershell
# Default Skyrim paths
$skyrimPath = "C:\Program Files (x86)\Steam\steamapps\common\Skyrim"
$ckPath = $skyrimPath
$skseSdkPath = "C:\Development\SKSE"
$vsPath = "C:\Program Files\Microsoft Visual Studio\2022\Community"

# Output configuration
$modName = "EnchantmentIndicator"
$modVersion = "1.0.0"
$buildOutput = "build_output"
```

Modify these paths if your tools are installed elsewhere.

---

## Build Output Structure

After a successful build, you'll have:

```
build_output/
└── EnchantmentIndicator_v1.0/
    ├── Scripts/
    │   ├── EnchantmentIndicator_Global.pex
    │   ├── EnchantmentIndicator_Quest.pex
    │   └── EnchantmentKnownChecker.pex
    ├── UI/
    │   ├── InventoryListPanelEI.swf
    │   ├── BarterMenuEI.swf
    │   └── EnchantmentIndicator_SWFUI.swf
    ├── Docs/
    │   ├── COMPLETE_GUIDE.md
    │   ├── QUICKSTART.md
    │   └── ...
    ├── README.txt
    ├── INFO.txt
    └── MANIFEST.txt
```

---

## What Each Build Step Does

### Step 1: Papyrus Script Compilation

**Input:** `source/scripts/*.psc`  
**Output:** `Scripts/*.pex`

Compiles Papyrus source files using the Creation Kit's compiler:
- `EnchantmentIndicator_Global.psc` → `EnchantmentIndicator_Global.pex`
- `EnchantmentIndicator_Quest.psc` → `EnchantmentIndicator_Quest.pex`
- `EnchantmentKnownChecker.psc` → `EnchantmentKnownChecker.pex`

**Dependencies:** Creation Kit with Papyrus Compiler

### Step 2: ActionScript Compilation

**Input:** `source/ui/skyui_custom/*.as`  
**Output:** `UI/*.swf`

Compiles ActionScript 2 files using mtxc or Flex SDK:
- `InventoryListPanelEI.as` → `InventoryListPanelEI.swf`
- `BarterMenuEI.as` → `BarterMenuEI.swf`
- `EnchantmentIndicator_SWFUI.as` → `EnchantmentIndicator_SWFUI.swf`

**Dependencies:** mtxc or Adobe Flex SDK

### Step 3: SKSE Plugin Build (Optional)

**Input:** `source/skse/*.cpp`  
**Output:** `SKSE/Plugins/*.dll`

Builds C++ SKSE plugin using Visual Studio:
- Requires Visual Studio 2019+
- Requires SKSE SDK
- Must manually set up VS project (see SKSE_BUILD_GUIDE.md)

**Note:** This step is optional. The mod works with or without the plugin.

### Step 4: Supporting Files

- Copy documentation (`docs/*.md` → `Docs/`)
- Create INFO.txt (build metadata)
- Create README.txt (installation guide)
- Create MANIFEST.txt (version info)

---

## Troubleshooting

### "Papyrus Compiler not found"

**Error:**
```
[✗] Papyrus Compiler not found at: C:\...\Papyrus Compiler\PapyrusCompiler.exe
```

**Solutions:**
1. Verify Creation Kit is installed: `C:\Program Files (x86)\Steam\steamapps\common\Skyrim\`
2. Check Papyrus Compiler exists: `...\Skyrim\Papyrus Compiler\PapyrusCompiler.exe`
3. Edit `build.config.ps1` with correct path
4. Run from correct directory

### "ActionScript compiler not found"

**Error:**
```
[!] No ActionScript compiler found (mtxc or Flex SDK)
```

**Solutions:**
1. Install Adobe Flex SDK: https://www.adobe.com/products/flex/
2. Or install Creation Kit which includes mtxc
3. Or run build with: `.\build.ps1 -SkipActionScript`
4. Manually compile later using tools

### "Build output is empty"

**Cause:**
Compilers ran but produced no output

**Solutions:**
1. Check error log for details
2. Verify source files exist
3. Check file permissions
4. Run build script in Administrator mode

### Scripts won't compile in Creation Kit later

**Possible causes:**
1. .pex files are outdated
2. Dependencies missing
3. Script syntax errors

**Solutions:**
1. Delete old .pex files, recompile
2. Check build log for warnings
3. Review source scripts for errors

---

## Advanced: Custom Build Targets

You can create custom PowerShell scripts to build specific components:

```powershell
# Build only Papyrus scripts
.\build.ps1 -SkipActionScript -SkipSKSE

# Build only ActionScript
.\build.ps1 -SkipPapyrus (if flag supported)

# Clean and rebuild everything
.\build.ps1 -Clean

# Rebuild without dialog
.\build.ps1 | Out-Null
```

---

## CI/CD with GitHub Actions

The GitHub Actions workflow (`.github/workflows/build.yml`) automatically:

1. **Validates** source files on every push
2. **Checks** syntax of all scripts
3. **Creates** build output structure
4. **Uploads** artifacts for download
5. **Creates** releases on git tags

**To use:**
1. Push code to GitHub
2. Go to Actions tab
3. View workflow progress
4. Download artifacts

**To create a release:**
```bash
git tag v1.0.0
git push --tags
```

This triggers automatic release creation with compiled files.

---

## Manual Compilation (If Build Scripts Fail)

### Papyrus Scripts

```bash
# Run from Skyrim directory
cd "C:\Program Files (x86)\Steam\steamapps\common\Skyrim"

# Compile individual script
"Papyrus Compiler\PapyrusCompiler.exe" "path\to\EnchantmentIndicator_Global.psc"

# Check for .pex output
ls "path\to\EnchantmentIndicator_Global.pex"
```

### ActionScript Files

```bash
# Using mtxc
mtxc -version 10.0 InventoryListPanelEI.as -output InventoryListPanelEI.swf

# Using Flex SDK mxmlc
mxmlc -target-player=10.0 InventoryListPanelEI.as -output InventoryListPanelEI.swf
```

### SKSE Plugin

See `docs/SKSE_BUILD_GUIDE.md` for detailed C++ compilation steps.

---

## Next Steps After Build

1. **Review Output:** Check `build_output\EnchantmentIndicator_v1.0\`
2. **Create .esp:** Use Creation Kit (see docs/QUICKSTART.md)
3. **Test:** Load in Skyrim LE
4. **Deploy:** Copy to mod manager or distribute

---

## Build Frequently Asked Questions

**Q: Can I build on Linux?**  
A: Use Docker: `docker build -t ei . && docker run ...`

**Q: Can I skip certain components?**  
A: Yes, use build flags:
- `-SkipActionScript` - Skip .as → .swf
- `-SkipSKSE` - Skip SKSE plugin
- `-SkipPapyrus` - (if supported)

**Q: How long does a build take?**  
A: ~1-2 minutes for full build, 30 seconds for Papyrus only

**Q: Where's the .esp file?**  
A: Must be created separately in Creation Kit (not auto-generated)

**Q: Can I modify the build process?**  
A: Yes, edit `build.ps1` or `build.bat` directly

**Q: What if build fails?**  
A: Check error messages, see Troubleshooting section above

---

## Environment Variables (Advanced)

You can override build config with environment variables:

```powershell
# PowerShell
$env:SKYRIM_PATH = "D:\Games\Skyrim"
$env:MOD_VERSION = "1.1.0"
.\build.ps1

# Command Prompt
set SKYRIM_PATH=D:\Games\Skyrim
build.bat
```

---

## Build Success Checklist

After build completes, verify:

- [ ] No error messages in output
- [ ] `build_output` folder created
- [ ] `Scripts\*.pex` files present
- [ ] `UI\*.swf` files present (if not skipped)
- [ ] `README.txt` and `INFO.txt` exist
- [ ] Documentation copied
- [ ] File timestamps recent (not old cached files)

If all above are ✓, your build was successful!

---

## Support

If build fails:

1. Check the **Troubleshooting** section above
2. Review **docs/COMPLETE_GUIDE.md** for detailed info
3. Check **docs/SKSE_BUILD_GUIDE.md** for SKSE-specific help
4. Verify tool installations
5. Run build in Administrator mode
6. Check file permissions on source/output directories

---

**Happy Building!** 🏗️✨
