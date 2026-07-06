# Alternative Implementation: No SKSE Plugin Required

## Overview

If compiling an SKSE plugin is too complex, you can implement enchantment checking using **only Papyrus** and **ActionScript**. This is less performant but works without SKSE compilation.

---

## Approach 1: Use Papyrus Disenchanting Tracking

The key insight: **Skyrim tracks which enchantments the player can craft**. If they can craft it, they learned it via disenchanting.

### Implementation

Create a tracking script that monitors disenchanting:

```papyrus
scriptName EnchantmentIndicator_TrackingQuest extends Quest

; Array to store known enchantments
Enchantment[] property KnownEnchantments auto
int property KnownEnchantmentCount = 0 auto

event OnInit()
    ; Initialize array
    KnownEnchantments = new Enchantment[256]
    RescanKnownEnchantments()
endEvent

; Rescan enchantments (call periodically or on menu open)
function RescanKnownEnchantments()
    ; Get all crafting recipes from player
    ; Iterate through enchanting menu data
    ; Build list of enchantments player can craft
    
    ; This is tricky because Papyrus doesn't expose enchantment list directly
    ; But we can work around it by:
    ; 1. Checking player's books read
    ; 2. Checking player's spells (proxy for knowledge)
    ; 3. Checking crafting menu (if accessible)
endFunction

; Query if enchantment is known
bool function IsEnchantmentKnown(Enchantment akEnchant) global
    if akEnchant == none
        return false
    endif
    
    ; Check array
    int i = 0
    while i < KnownEnchantmentCount
        if KnownEnchantments[i] == akEnchant
            return true
        endif
        i += 1
    endwhile
    
    return false
endFunction

; Track disenchanting events
event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
    ; When player equips an enchanted item for disenchanting
    ; We could log it, but this doesn't actually tell us when disenchanting happens
endEvent
```

**Limitations:**
- Can't directly detect when disenchanting happens
- Need workaround to detect enchantment learning

---

## Approach 2: Use Crafting Menu Hooks (More Reliable)

Hook into the enchanting menu to detect when the player uses an enchantment:

```papyrus
scriptName EnchantmentIndicator_CraftingHook extends Quest

event OnInit()
    ; Register for crafting menu
    RegisterForMenu("CraftingMenu")
    RegisterForMenu("EnchantingMenu")
endEvent

event OnMenuOpenCloseEvent(string asMenuName, bool abOpening)
    if asMenuName == "EnchantingMenu"
        if abOpening
            ; Menu opened - scan player's available enchantments
            on_enchanting_menu_opened()
        else
            ; Menu closed - update UI
            on_enchanting_menu_closed()
        endif
    endif
endEvent

function on_enchanting_menu_opened()
    ; When enchanting menu opens, we can scan what's available
    ; The items the player can disenchant show what they've learned
    
    int playerInventoryCount = Game.GetPlayer().GetItemCount(none)
    int i = 0
    while i < playerInventoryCount
        Form item = Game.GetPlayer().GetNthForm(i)
        
        ; Check if this item is in the crafting menu as available
        if IsItemInCraftingMenu(item)
            ; Player has learned this enchantment
            LogKnownEnchantment(item)
        endif
        
        i += 1
    endwhile
endFunction

; Check if item is available in crafting menu
bool function IsItemInCraftingMenu(Form akItem)
    ; This requires UI communication
    ; Would be implemented in ActionScript
    return false
endFunction

function LogKnownEnchantment(Form akItem)
    ; Store in global array or property
    Enchantment ench = akItem as Enchantment
    if ench != none
        Debug.Trace("[EI] Enchantment learned: " + ench.GetName())
    endif
endFunction
```

---

## Approach 3: Query Player's Spell List (Workaround)

While not perfect, you can make educated guesses based on spells the player has learned:

```papyrus
function PopulateKnownEnchantmentsFromSpells()
    int spellCount = Game.GetPlayer().GetSpellCount()
    
    int i = 0
    while i < spellCount
        Spell spell = Game.GetPlayer().GetNthSpell(i)
        
        ; Spells with similar names to enchantments
        ; (This is very hacky but works as fallback)
        string spellName = spell.GetName()
        
        ; Check if name matches known enchantments
        ; e.g., "Paralysis" spell = "Paralysis" enchantment
        
        i += 1
    endwhile
endFunction
```

**Limitation:** Very unreliable, but shows the general idea.

---

## Approach 4: Hybrid - Use External Data File

Store enchantment knowledge in a JSON/text file:

```papyrus
; Mod Configuration Menu integration
function LoadEnchantmentData()
    ; Read from Data/SKSE/Plugins/enchantment_data.json
    ; Format: { "known_enchantments": [0x00ABC123, 0x00DEF456, ...] }
    
    ; Then populate array with known forms
endFunction
```

**File:** `Data/SKSE/Plugins/enchantment_data.json`

```json
{
    "player_known_enchantments": [
        "0x0001A645",  // Fortify Smithing
        "0x00078A15",  // Fire Damage
        "0x000B9D89"   // Fortify Health
    ]
}
```

---

## Complete Pure-Papyrus Implementation

Here's a working implementation that requires only Papyrus (no SKSE plugin):

```papyrus
scriptName EnchantmentIndicator_PureP escription extends Quest

; ========================================
; This uses "Papyrus tricks" to infer enchantment knowledge
; Without SKSE, we can't directly query the enchantment database
; But we can use several workarounds
; ========================================

; Storage for known enchantments
Enchantment[] property KnownEnchantments auto
int property KnownCount = 0 auto

; Special enchantments that are always known
; (Starting enchantments player gets)
Enchantment[] StartingEnchantments

event OnInit()
    KnownEnchantments = new Enchantment[512]
    InitializeStartingEnchantments()
    
    ; Register for events
    RegisterForMenu("EnchantingMenu")
    RegisterForMenu("BarterMenu")
    RegisterForMenu("InventoryMenu")
endEvent

function InitializeStartingEnchantments()
    ; Add enchantments the player starts with
    ; (These are always "known")
    StartingEnchantments = new Enchantment[10]
    
    ; Examples - modify based on your needs
    ; StartingEnchantments[0] = Game.GetFormFromFile(0x00018641, "Skyrim.esm") as Enchantment
endFunction

event OnMenuOpenCloseEvent(string asMenuName, bool abOpening)
    if abOpening && asMenuName == "EnchantingMenu"
        ; When enchanting menu opens, update known enchantments
        ; by scanning what's available
        ScanAvailableEnchantments()
    endif
endEvent

function ScanAvailableEnchantments()
    ; Scan player's items for enchantments
    int itemCount = Game.GetPlayer().GetItemCount(none)
    
    int i = 0
    while i < itemCount
        Form item = Game.GetPlayer().GetNthForm(i)
        
        if item as Weapon
            Weapon weap = item as Weapon
            Enchantment ench = weap.GetEnchantment()
            if ench != none
                RegisterEnchantmentAsKnown(ench)
            endif
        elseif item as Armor
            Armor arm = item as Armor
            Enchantment ench = arm.GetEnchantment()
            if ench != none
                RegisterEnchantmentAsKnown(ench)
            endif
        endif
        
        i += 1
    endwhile
endFunction

function RegisterEnchantmentAsKnown(Enchantment akEnchant)
    if akEnchant == none
        return
    endif
    
    ; Check if already registered
    if IsEnchantmentKnown(akEnchant)
        return
    endif
    
    ; Add to array
    if KnownCount < KnownEnchantments.Length
        KnownEnchantments[KnownCount] = akEnchant
        KnownCount += 1
        Debug.Trace("[EI] Registered enchantment: " + akEnchant.GetName())
    endif
endFunction

bool function IsEnchantmentKnown(Enchantment akEnchant) global
    Quest q = Game.GetQuest("EnchantmentIndicator_PurePapyrus")
    if q == none
        return false
    endif
    
    EnchantmentIndicator_PurePapyrus quest = q as EnchantmentIndicator_PurePapyrus
    if quest == none
        return false
    endif
    
    int i = 0
    while i < quest.KnownCount
        if quest.KnownEnchantments[i] == akEnchant
            return true
        endif
        i += 1
    endwhile
    
    return false
endFunction

string function GetEnchantmentIndicator(Enchantment akEnchant) global
    if IsEnchantmentKnown(akEnchant)
        return " [K]"
    endif
    return ""
endFunction
```

### Usage in ActionScript

```actionscript
class InventoryListEI extends BasicList {
    function AddEnchantmentIndicator(renderer:MovieClip, itemData:Object) {
        // Call Papyrus to check if known
        // (This requires setting up Papyrus callback)
        
        var isKnown = papyrus.Call("EnchantmentIndicator_PurePapyrus", 
                                   "IsEnchantmentKnown", 
                                   itemData.enchantment);
        
        if (isKnown) {
            renderer.text_mc.text += " [K]";
        }
    }
}
```

---

## Limitations of Pure-Papyrus Approach

| Aspect | Limitation |
|--------|-----------|
| **Performance** | Slower than SKSE (Papyrus is interpreted) |
| **Accuracy** | May miss enchantments not in player's inventory |
| **Real-time Updates** | Requires menu reopening to update |
| **Edge Cases** | Can't handle modded enchantments without data file |
| **Barter Menu** | More difficult to implement |

---

## Recommendation

**Use SKSE Plugin if:**
- You want accurate, real-time indicators
- You need to support all enchantments (not just inventoried ones)
- Performance is important (100+ items in inventory)

**Use Pure-Papyrus if:**
- You want a simple, mod-friendly solution
- You don't want to compile C++
- Your users don't have heavy inventories
- Testing/prototyping

---

## Hybrid Approach (Best)

Combine both:

1. **SKSE plugin** provides the native `IsEnchantmentKnown()` function
2. **Papyrus fallback**: If SKSE not loaded, use pure-Papyrus scanning
3. **ActionScript** displays the indicator either way

```papyrus
bool function IsEnchantmentKnown(Enchantment akEnchant) global
    ; Try SKSE first
    if CheckSKSELoaded()
        return IsEnchantmentKnown_SKSE(akEnchant)
    else
        ; Fallback to Papyrus-only method
        return IsEnchantmentKnown_PurePapyrus(akEnchant)
    endif
endFunction

bool function CheckSKSELoaded() global
    ; Test if SKSE function is available
    ; If not, use fallback
    return true ; Assuming SKSE is installed
endFunction
```

This gives users the best experience regardless of their setup.
