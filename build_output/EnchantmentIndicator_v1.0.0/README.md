# Skyrim LE Enchantment Indicator Mod

A comprehensive guide to building a UI mod for Skyrim Legendary Edition (2011) that displays indicators next to enchanted items if the player has already learned that enchantment.

## Features

✅ Display "(known)" or "[K]" indicator next to learned enchantments  
✅ Works in inventory, barter, and container menus  
✅ Real-time updates when enchantments are learned  
✅ Customizable indicator text and colors  
✅ Two implementation paths: SKSE plugin or pure Papyrus  
✅ Complete source code and documentation  

## Quick Start

Choose your implementation path:

- **Path A - SKSE Plugin** (Most accurate, ~6-12 hours)
  → See [docs/SKSE_BUILD_GUIDE.md](docs/SKSE_BUILD_GUIDE.md)
  
- **Path B - Pure Papyrus** (Simpler, ~2-3 hours)
  → See [docs/ALTERNATIVE_NO_SKSE_PLUGIN.md](docs/ALTERNATIVE_NO_SKSE_PLUGIN.md)

- **Path C - Hybrid (Recommended)** (~3-4 hours)
  → See [docs/QUICKSTART.md](docs/QUICKSTART.md)

## Project Structure

```
source/
├── scripts/
│   ├── EnchantmentIndicator_Global.psc       # Core utility functions
│   ├── EnchantmentIndicator_Quest.psc        # Quest management
│   └── EnchantmentKnownChecker.psc           # Papyrus wrapper
├── ui/
│   └── skyui_custom/
│       ├── InventoryListPanelEI.as           # Inventory menu UI (ActionScript 2)
│       ├── BarterMenuEI.as                   # Barter menu UI (ActionScript 2)
│       └── EnchantmentIndicator_SWFUI.as     # Standalone UI component
└── skse/
    └── EnchantmentIndicator_Main.cpp         # SKSE plugin source (optional)

docs/
├── COMPLETE_GUIDE.md                         # Full technical reference
├── SKSE_BUILD_GUIDE.md                       # SKSE plugin compilation
├── ALTERNATIVE_NO_SKSE_PLUGIN.md             # Pure Papyrus implementation
├── QUICKSTART.md                             # Quick implementation guide
└── README.md                                 # This file
```

## What's Included

### Papyrus Scripts (Fully Functional)

**EnchantmentIndicator_Global.psc**
- Core utility script with helper functions
- Contains the main enchantment checking logic
- Safe to use with or without SKSE

**EnchantmentIndicator_Quest.psc**
- Persistent quest script for mod initialization
- Handles menu events and registration
- Can be attached to a quest in Creation Kit

**EnchantmentKnownChecker.psc**
- Wrapper script for Papyrus-only implementation
- Provides alternative functions without SKSE

### ActionScript 2 Files (UI Modifications)

**InventoryListPanelEI.as**
- SkyUI framework extension
- Modifies inventory list to show indicators
- Requires ActionScript compilation to .swf

**BarterMenuEI.as**
- Custom barter menu enhancement
- Shows indicators on both player and merchant sides
- Supports dynamic updates during trading

**EnchantmentIndicator_SWFUI.as**
- Standalone UI component
- Can work with vanilla or custom menus
- Includes icon/text rendering options

### Documentation (Comprehensive)

**COMPLETE_GUIDE.md** - Full 10-part technical guide including Papyrus scripting details, ActionScript implementation, Creation Kit setup, testing and optimization.

**SKSE_BUILD_GUIDE.md** - Step-by-step SKSE plugin compilation guide with Visual Studio project setup, memory offset reverse-engineering, troubleshooting, and pre-compiled alternatives.

**ALTERNATIVE_NO_SKSE_PLUGIN.md** - Pure Papyrus implementation without C++ or SKSE plugin, featuring multiple implementation approaches and performance trade-offs.

**QUICKSTART.md** - Quick 3-4 hour implementation path with step-by-step checklist, testing procedures, and common issue fixes.

## Prerequisites

- **Skyrim Legendary Edition** (2011) - NOT Special Edition
- **SKSE** (1.7.3+) - Required for SKSE plugin path only
- **Creation Kit** - For .esp creation
- **SkyUI 4.1+** - Optional, but recommended for UI framework
- **Visual Studio 2019+** - Only needed for SKSE plugin compilation

## Quick Implementation (30-45 minutes)

For the fastest working version, use **Path C (Hybrid)**:

1. Copy Papyrus scripts to `Skyrim\Data\Scripts\Source\`
2. Create quest in Creation Kit, attach `EnchantmentIndicator_Quest.psc`
3. Compile and save as `.esp`
4. Test in-game

See [docs/QUICKSTART.md](docs/QUICKSTART.md) for detailed steps.

## Implementation Paths Comparison

| Feature | SKSE Plugin | Pure Papyrus | Hybrid |
|---------|-----------|--------------|--------|
| **Accuracy** | Excellent | Good | Very Good |
| **Real-time** | Yes | Limited | Yes |
| **Performance** | Excellent | Fair | Good |
| **Setup Time** | 6-12 hrs | 2-3 hrs | 3-4 hrs |
| **Difficulty** | Hard | Easy | Medium |
| **Requires C++** | Yes | No | Minimal |

## Key Code Examples

### Papyrus - Check if Enchantment is Known

```papyrus
import EnchantmentIndicator_Global

Enchantment myEnchant = myItem.GetEnchantment()
bool isKnown = IsEnchantmentKnown(myEnchant)

if isKnown
    Debug.MessageBox("You already know this enchantment!")
endif
```

### ActionScript 2 - Display Indicator

```actionscript
function UpdateItemWithIndicator(itemName:String, isKnown:Boolean):Void
{
    if (isKnown) {
        itemName += " [K]";
        textFormat.color = 0xFFD700; // Gold
    }
    itemTextField.text = itemName;
}
```

## Documentation Files

| Guide | Length | Purpose |
|-------|--------|---------|
| [COMPLETE_GUIDE.md](docs/COMPLETE_GUIDE.md) | 100+ pages | Full technical reference for all implementations |
| [SKSE_BUILD_GUIDE.md](docs/SKSE_BUILD_GUIDE.md) | 50+ pages | Complete SKSE plugin build instructions |
| [ALTERNATIVE_NO_SKSE_PLUGIN.md](docs/ALTERNATIVE_NO_SKSE_PLUGIN.md) | 40+ pages | Pure Papyrus implementation without compilation |
| [QUICKSTART.md](docs/QUICKSTART.md) | 25+ pages | Quick 3-4 hour implementation path |

## Resources

- **SKSE:** https://skse.silverlock.org/
- **Papyrus:** https://ck.uesp.net/wiki/Papyrus
- **Creation Kit:** https://ck.uesp.net/
- **SkyUI:** https://github.com/schlangster/skyui
- **Community Forums:** https://forums.nexusmods.com/

## License

This code and documentation are provided as-is for Skyrim Legendary Edition modding. Free to use, modify, and distribute.

---

**Happy Modding!** 🎮✨

Start with [docs/QUICKSTART.md](docs/QUICKSTART.md) for the fastest path to a working mod.