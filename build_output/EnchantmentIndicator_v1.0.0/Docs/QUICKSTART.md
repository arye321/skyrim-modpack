# Quick-Start Implementation Guide

## Choose Your Path (Pick One)

### Path A: Full SKSE Plugin Solution (Recommended, Most Accurate)
- **Pros:** Real-time, accurate, handles all enchantments
- **Cons:** Requires compiling C++
- **Time:** 4-8 hours (including reverse-engineering if needed)
- **See:** `docs/SKSE_BUILD_GUIDE.md` + `docs/COMPLETE_GUIDE.md` Part 1-5

### Path B: Pure Papyrus Solution (Simpler)
- **Pros:** Easy to install, no compilation
- **Cons:** Less accurate, slower, requires manual enchantment registration
- **Time:** 2-3 hours
- **See:** `docs/ALTERNATIVE_NO_SKSE_PLUGIN.md`

### Path C: Simplified Hybrid (Recommended for Testing)
- **Pros:** Works with or without SKSE, good balance
- **Cons:** Moderate complexity
- **Time:** 3-4 hours
- **See:** Below (this guide)

---

## Quick Start: Path C (Recommended)

This is the fastest path to a working mod.

### Step 1: Set Up Creation Kit (15 minutes)

1. Download Skyrim LE Creation Kit
   - https://www.nexusmods.com/skyrim/mods/11765
   
2. Install to Skyrim folder

3. Set up scripts folder:
   ```
   Skyrim\Data\Scripts\
   Skyrim\Data\Scripts\Source\  ← Put .psc files here
   ```

### Step 2: Prepare Papyrus Scripts (10 minutes)

Copy these files to `Skyrim\Data\Scripts\Source\`:

```
✓ EnchantmentIndicator_Global.psc
✓ EnchantmentIndicator_Quest.psc
✓ EnchantmentKnownChecker.psc
```

### Step 3: Create the Mod in Creation Kit (30 minutes)

#### 3.1 Create Quest

1. Open Creation Kit
2. File → New
3. Object Window → Quests → [New]
4. Quest ID: `EnchantmentIndicatorQuest`
5. Quest → Targets → None (or set custom)
6. Check: "Start Game Enabled" ✓
7. Stages → [New Stage] → Result Script → Script Type: `EnchantmentIndicator_Quest`

#### 3.2 Create Globals (Optional but Recommended)

1. Object Window → Globals → [New]
2. EditorID: `EI_KnownColorR` (Value: 1.0) - Red channel for color (0.0-1.0)
3. EditorID: `EI_KnownColorG` (Value: 1.0) - Green channel (0.0-1.0)
4. EditorID: `EI_KnownColorB` (Value: 0.0) - Blue channel (0.0-1.0)

This lets users customize the indicator color.

#### 3.3 Compile Scripts

1. Gameplay → Scripts
2. Filter by class: Select `EnchantmentIndicator_*`
3. Right-click → Compile
4. Check for errors in debug window

### Step 4: Create Basic UI Overlay (1-2 hours)

#### Option A: Use SkyUI Framework (If using SkyUI)

1. Get SkyUI source from: https://github.com/schlangster/skyui

2. Create file: `source/ui/skyui_custom/CustomEnchantmentPanel.as`

```actionscript
import gfx.core.UIComponent;
import skyui.util.Delegate;

class CustomEnchantmentPanel extends UIComponent
{
    private var targetList:MovieClip;
    
    function onLoad():Void
    {
        super.onLoad();
        InitializePanel();
    }
    
    function InitializePanel():Void
    {
        // Hook into inventory list updates
        _root.InventoryMenu.itemList.onEntryRendered = 
            Delegate.create(this, OnItemRendered);
    }
    
    function OnItemRendered(entryObject:Object, entryRenderer:MovieClip):Void
    {
        if (!entryObject || !entryObject.enchanted)
            return;
        
        // Add indicator
        var indicator = " [K]";
        entryRenderer.text_tf.text += indicator;
        
        // Color it gold
        var fmt = new TextFormat();
        fmt.color = 0xFFD700;
        entryRenderer.text_tf.setTextFormat(fmt);
    }
}
```

3. Compile to `.swf`:
   ```bash
   mtxc -version 10.0 CustomEnchantmentPanel.as -output CustomEnchantmentPanel.swf
   ```

4. Place in: `Data/UI/CustomEnchantmentPanel.swf`

#### Option B: Simpler Text Overlay (No SkyUI Required)

Create a minimal ActionScript that doesn't require SkyUI:

```actionscript
// Simple overlay - works with vanilla or SkyUI
class EnchantmentIndicatorSimple
{
    static function PatchInventoryMenu():Void
    {
        var inventoryMC = _root.InventoryMenu;
        
        // Patch the item renderer function
        var originalRender = inventoryMC.itemList.onItemRendered;
        inventoryMC.itemList.onItemRendered = function(item, renderer) {
            originalRender.call(this, item, renderer);
            
            if (item.enchanted) {
                renderer.text_tf.text += " [K]";
            }
        };
    }
}

// Call on menu open
_root.InventoryMenu.onOpen = function() {
    super.onOpen();
    EnchantmentIndicatorSimple.PatchInventoryMenu();
};
```

### Step 5: Create .esp Plugin File (20 minutes)

In Creation Kit:

1. File → Save As: `EnchantmentIndicator.esp`
2. Save in `Data/` folder

### Step 6: Package for Distribution (10 minutes)

Directory structure for release:

```
EnchantmentIndicator_v1.0/
├── Data/
│   ├── Scripts/
│   │   ├── EnchantmentIndicator_Global.pex
│   │   ├── EnchantmentIndicator_Quest.pex
│   │   └── EnchantmentKnownChecker.pex
│   ├── UI/
│   │   └── CustomEnchantmentPanel.swf
│   └── (no esp file needed if using mod manager correctly)
├── EnchantmentIndicator.esp
├── README.txt
└── VERSION.txt
```

### Step 7: Test (30-60 minutes)

1. **Start new game in Skyrim LE**

2. **Test without learning enchantment:**
   - Open inventory
   - Equip an enchanted item (don't disenchant)
   - Indicator should NOT appear

3. **Test with learning enchantment:**
   - Find an enchanted item
   - Go to arcane enchanter
   - Disenchant it
   - Open inventory
   - Indicator SHOULD appear

4. **Debug Console (if not working):**
   ```
   help EnchantmentIndicator_Global
   ```
   
   Should return: "1"

   If returns 0 or error, script didn't load.

### Step 8: Distribute (10 minutes)

Upload to:
- Nexus Mods: https://www.nexusmods.com/skyrim/
- ModDB: https://www.moddb.com/mods
- GitHub: https://github.com/

---

## Complete File Checklist

Before you start, make sure you have:

### Papyrus Scripts ✓
- [ ] `source/scripts/EnchantmentIndicator_Global.psc`
- [ ] `source/scripts/EnchantmentIndicator_Quest.psc`
- [ ] `source/scripts/EnchantmentKnownChecker.psc`

### ActionScript Files ✓
- [ ] `source/ui/skyui_custom/InventoryListPanelEI.as`
- [ ] `source/ui/skyui_custom/BarterMenuEI.as`
- [ ] `source/ui/skyui_custom/EnchantmentIndicator_SWFUI.as`

### Documentation ✓
- [ ] `docs/COMPLETE_GUIDE.md` (Full technical reference)
- [ ] `docs/SKSE_BUILD_GUIDE.md` (If using SKSE plugin)
- [ ] `docs/ALTERNATIVE_NO_SKSE_PLUGIN.md` (Papyrus-only version)
- [ ] `docs/QUICKSTART.md` (This file)

### Optional (for SKSE plugin version)
- [ ] `source/skse/EnchantmentIndicator_Main.cpp`

---

## Timeline Summary

| Path | Time | Difficulty | Result Quality |
|------|------|-----------|-----------------|
| **Path A (SKSE)** | 6-12 hrs | Hard | Excellent |
| **Path B (Pure Papyrus)** | 2-3 hrs | Easy | Good |
| **Path C (Hybrid, Recommended)** | 3-4 hrs | Medium | Very Good |

---

## Common Issues & Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| Indicator never appears | Scripts not loaded | Check quest enabled, compile scripts |
| Game crashes | Script error | Check Creation Kit logs for syntax errors |
| Indicator appears for all items | Wrong check logic | Verify `IsEnchantmentKnown()` logic |
| Performance lag with large inventory | Checking too many items | Batch updates instead of per-item |
| Barter menu not working | UI not hooked | Verify ActionScript in barter menu .swf |

---

## Next Steps

1. Choose your path (A, B, or C)
2. Follow the guide for that path
3. Test thoroughly
4. Get feedback from community
5. Iterate and improve

### For More Help

- **SKSE Forums:** https://forums.nexusmods.com/index.php
- **Skyrim Modding Discord:** Join community Discord servers
- **GitHub Issues:** If publishing source code, enable issues for feedback

---

## Advanced Topics (After Getting Basics Working)

Once you have a working mod:

- Add configuration menu (MCM) for customization
- Add icon support instead of text
- Optimize for very large inventories (1000+ items)
- Multi-language support
- Integration with popular mod packs
- Creation Club compatibility (if needed)

---

## Congratulations!

Once complete, you'll have a fully functional enchantment indicator mod for Skyrim LE that shows players which enchantments they've already learned. This is a great foundation for more advanced inventory UI mods.

Enjoy! 🎮
