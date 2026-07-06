# SKSE Plugin Build Guide for Enchantment Indicator

## Prerequisites

### Software Required
1. **Visual Studio 2019 or 2022** (Community Edition is free)
   - Download: https://visualstudio.microsoft.com/vs/community/
   - Install with C++ development tools
   
2. **SKSE SDK** (Source Scripting Extender)
   - Download: https://skse.silverlock.org/
   - Extract to a working directory
   
3. **Skyrim LE Binaries**
   - Not always needed, but helpful for reverse-engineering
   - Path: `C:\Program Files (x86)\Steam\steamapps\common\Skyrim`

4. **IDA Pro or Ghidra** (Optional, for reverse-engineering)
   - For finding memory offsets
   - Ghidra is free: https://ghidra-sre.org/

---

## Step 1: Set Up Development Environment

### 1.1 Install Visual Studio 2019+

1. Download and run Visual Studio installer
2. Select: "Desktop development with C++"
3. Include: Windows 10/11 SDK, MSVC compiler
4. Complete installation (requires ~4 GB)

### 1.2 Extract SKSE SDK

```bash
# Extract to: C:\Development\SKSE or similar
unzip skse_0_13_6_universal.zip -d C:\Development\SKSE

# Directory structure:
# C:\Development\SKSE\
#   ├── skse_structure.txt
#   ├── src/
#   │   ├── skse/
#   │   │   ├── PluginAPI.h
#   │   │   ├── ScaleformAPI.h
#   │   │   ├── skse_version.h
#   │   │   └── ... (other headers)
#   │   ├── common/
#   │   └── ... (other source)
#   ├── obse/
#   └── readme_general.txt
```

### 1.3 Create Project Directory

```bash
mkdir C:\Development\EnchantmentIndicator
cd C:\Development\EnchantmentIndicator

# Copy SKSE SDK structure
xcopy C:\Development\SKSE\src\* .\ /s /e
```

---

## Step 2: Create Visual Studio Project

### 2.1 Create New Visual Studio Project

1. Open Visual Studio
2. File → New → Project
3. Select: "Empty Project" (C++)
4. Name: `EnchantmentIndicator`
5. Location: `C:\Development\EnchantmentIndicator`
6. Create

### 2.2 Configure Project Settings

**Right-click project → Properties:**

#### General
- Platform Toolset: Visual Studio 2019 (v142) or appropriate version
- Target Platform Version: Windows 10 / 11

#### Include Directories
Add to: Project Properties → C/C++ → General → Additional Include Directories

```
C:\Development\EnchantmentIndicator\skse\
C:\Development\EnchantmentIndicator\common\
```

#### Preprocessor Defines
Project Properties → C/C++ → Preprocessor → Preprocessor Definitions

```
_WINDLL
_CRT_SECURE_NO_WARNINGS
RUNTIME_VERSION=RUNTIME_VERSION_1_1_11_0
```

#### Output Settings
Project Properties → General → Output Directory

```
$(SolutionDir)build\$(Platform)\$(Configuration)\
```

#### Build Events
Project Properties → Build Events → Post-Build Event

```
copy "$(TargetPath)" "C:\Program Files (x86)\Steam\steamapps\common\Skyrim\Data\SKSE\Plugins\$(TargetFileName)"
```

---

## Step 3: Add Source Code

### 3.1 Create Source File

1. Right-click project → Add → New Item
2. Select: C++ File (.cpp)
3. Name: `EnchantmentIndicator_Main.cpp`
4. Add the provided source code

### 3.2 Create Header Files (if needed)

Create `EnchantmentIndicator.h`:

```cpp
#pragma once

#include "skse/PluginAPI.h"

class EnchantmentKnowledge
{
public:
    static bool IsEnchantmentKnown(PlayerCharacter* player, EnchantmentItem* ench);
    static bool InitializeOffsets();
    
private:
    static const UInt32 ENCHANTMENT_KNOWN_OFFSET; // Set via reverse-engineering
};
```

---

## Step 4: Reverse-Engineer Memory Addresses

This is the critical step. You need to find where Skyrim stores enchantment knowledge.

### Method 1: Using Skyrim's Functions (Recommended)

Look for functions in Skyrim.exe that reference enchantments:

```
- GetEnchantment()
- IsEnchantmentKnown()
- DisenchantItem()
- GetKnownEnchantments()
```

Use IDA Pro or Ghidra to find these functions:

1. Open Skyrim.exe in IDA Pro
2. Search for string: "enchant" or "disenchant"
3. Find the function that manages the player's enchantment list
4. Note the memory offsets

### Method 2: Using SKSE's Existing Patterns

Check existing SKSE plugins to see how they access character data:

```cpp
// Example from other SKSE plugins:
PlayerCharacter* player = *g_thePlayer;

// Access player's spell list (similar structure):
SpellItem** spellList = (SpellItem**)((UInt8*)player + 0x0A78); // Example offset

// For enchantments, look for similar offset:
// EnchantmentItem** enchList = (EnchantmentItem**)((UInt8*)player + 0x????);
```

### Method 3: Using Papyrus Property Reflection

Some data can be accessed through Papyrus properties, which helps identify memory locations.

---

## Step 5: Implement the Native Function

### Complete Implementation Example

Here's a more complete implementation (with placeholder offsets):

```cpp
#include "skse/PluginAPI.h"
#include "skse/ScaleformAPI.h"
#include <stdio.h>

IDebugLog gLog("enchantment_indicator.log");
PluginHandle g_pluginHandle = kPluginHandle_Invalid;

// Memory offsets (these need to be correct for your Skyrim version)
// Skyrim LE 1.9.32.0
namespace Offsets {
    const UInt32 PlayerCharacter_KnownEnchantments = 0x0C60; // Example - change as needed
    const UInt32 EnchantmentMap_Contains = 0x400000; // Example function address
}

// Custom structures that match Skyrim's memory layout
template <typename T>
class SimpleArray {
public:
    T* data;
    UInt32 count;
    UInt32 capacity;
    
    bool Contains(T element) const {
        for (UInt32 i = 0; i < count; ++i)
            if (data[i] == element)
                return true;
        return false;
    }
};

bool IsEnchantmentKnown(StaticFunctionTag* base, EnchantmentItem* enchantment)
{
    if (!enchantment) {
        gLog.Message("IsEnchantmentKnown: enchantment is NULL");
        return false;
    }
    
    PlayerCharacter* player = *g_thePlayer;
    if (!player) {
        gLog.Message("IsEnchantmentKnown: player is NULL");
        return false;
    }
    
    // Method 1: Direct memory access (requires correct offset)
    /*
    SimpleArray<EnchantmentItem*>* knownEnchantments = 
        (SimpleArray<EnchantmentItem*>*)((UInt8*)player + Offsets::PlayerCharacter_KnownEnchantments);
    
    if (knownEnchantments && knownEnchantments->Contains(enchantment)) {
        gLog.Message("Enchantment %08X is KNOWN", enchantment->formID);
        return true;
    }
    */
    
    // Method 2: Use Skyrim's internal function (if available)
    // This would require finding the actual function address
    
    gLog.Message("Enchantment %08X is UNKNOWN", enchantment->formID);
    return false;
}

bool RegisterFunctions(VMClassRegistry* registry)
{
    gLog.Message("Registering Papyrus functions...");
    
    registry->RegisterFunction(
        new NativeFunction1 <StaticFunctionTag, bool, EnchantmentItem*>(
            "IsEnchantmentKnown",
            "EnchantmentIndicator_Global",
            IsEnchantmentKnown,
            registry
        )
    );
    
    gLog.Message("Papyrus functions registered successfully");
    return true;
}

extern "C" {
    bool SKSEPlugin_Query(const SKSE_Interface* skse, PluginInfo* info) {
        gLog.OpenRelative(CSIDL_MYDOCUMENTS, "\\My Games\\Skyrim\\SKSE\\enchantment_indicator.log");
        
        info->infoVersion = PluginInfo::kInfoVersion;
        info->name = "EnchantmentIndicator";
        info->version = 0x00010000;
        
        if (skse->isEditor)
            return false;
        
        if (skse->skseVersion < 0x01070300) {
            gLog.Message("SKSE version too old: %08X", skse->skseVersion);
            return false;
        }
        
        return true;
    }
    
    bool SKSEPlugin_Load(const SKSE_Interface* skse) {
        gLog.Message("EnchantmentIndicator Plugin Load");
        
        g_pluginHandle = skse->GetPluginHandle();
        PapyrusInterface* papyrus = (PapyrusInterface*)skse->QueryInterface(kInterface_Papyrus);
        
        if (!papyrus)
            return false;
        
        return papyrus->Register(RegisterFunctions);
    }
};
```

---

## Step 6: Build and Deploy

### 6.1 Build the Plugin

1. Visual Studio → Build → Build Solution
2. Select: Release x86 (for Skyrim LE 32-bit)
3. Wait for build to complete

### 6.2 Check Build Output

```
Build: 1 succeeded, 0 failed
Output: C:\Development\EnchantmentIndicator\build\Win32\Release\EnchantmentIndicator.dll
```

### 6.3 Deploy to Skyrim

The post-build event should auto-copy, or manually:

```bash
copy EnchantmentIndicator.dll "C:\Program Files (x86)\Steam\steamapps\common\Skyrim\Data\SKSE\Plugins\"
```

Verify:
```
C:\Program Files (x86)\Steam\steamapps\common\Skyrim\
└── Data\
    └── SKSE\
        └── Plugins\
            └── EnchantmentIndicator.dll ✓
```

### 6.4 Test Plugin Loading

1. Start Skyrim with SKSE
2. Open console: `tilde key (~)`
3. Type: `GetModByName EnchantmentIndicator`
4. Should return a number (not 0)

If you get an error, check:
- `My Documents\My Games\Skyrim\SKSE\enchantment_indicator.log`

---

## Step 7: Troubleshooting Build Issues

### Error: "Cannot find skse_version.h"

**Fix:** Add include path in Project Properties → C/C++ → General → Additional Include Directories

```
C:\Development\SKSE\src\
```

### Error: "Unresolved external symbol"

**Fix:** You're trying to use SKSE functions that need additional source files. Add all .cpp files from SKSE\src\common\ to your project.

### Error: "Plugin fails to load in Skyrim"

**Fix:** Check the log file for specific errors:
```
My Documents\My Games\Skyrim\SKSE\enchantment_indicator.log
```

Common issues:
- SKSE version mismatch
- Wrong architecture (need Win32, not x64 for LE)
- Plugin version conflicts

---

## Alternative: Use Pre-Compiled SKSE Plugin

If you don't want to compile, you can use a pre-made SKSE plugin that provides enchantment checking functionality. Some mods that do this:

- **Item Enumeration Fix**: Has some enchantment handling
- **SKSE Core**: Provides basic enchantment functions
- **Papyrus Tweaks**: Extended enchantment API

Or request a compiled plugin from:
- SKSE Community: https://forums.nexusmods.com/index.php
- Skyrim Modding Discord

---

## Step 8: (Advanced) Find the Actual Memory Offset

Once you have a working build, you can test and refine offsets:

```cpp
// In your code, add a test function:
void TestEnchantmentKnowledge() {
    PlayerCharacter* player = *g_thePlayer;
    
    // Try different offsets
    for (UInt32 offset = 0x0A00; offset < 0x0D00; offset += 4) {
        void** ptr = (void**)((UInt8*)player + offset);
        gLog.Message("Offset 0x%04X: %08X", offset, *ptr);
    }
}
```

Then in-game, call this test and check the log. Look for data that matches known enchantments.

---

## Resources

- SKSE SDK: https://skse.silverlock.org/
- SKSE GitHub: https://github.com/ianpatt/skse
- Reverse Engineering Guide: https://www.oreilly.com/library/view/reverse-engineering/9781118010495/
- IDA Pro Tutorial: https://www.hex-rays.com/products/ida/support/tutorials/
- Skyrim Memory Addresses (Community DB): https://en.uesp.net/wiki/Skyrim_Mod:Memory_Addresses

---

## Summary

To build the SKSE plugin:

1. ✓ Install Visual Studio 2019+
2. ✓ Download and extract SKSE SDK
3. ✓ Create VS project with proper settings
4. ✓ Add source code (provided)
5. → **Find correct memory offsets** (hardest part)
6. → Build and test
7. → Deploy to Skyrim\Data\SKSE\Plugins\

The main challenge is finding the correct memory offsets for your Skyrim version. Consider asking in SKSE forums or using existing plugins as reference.
