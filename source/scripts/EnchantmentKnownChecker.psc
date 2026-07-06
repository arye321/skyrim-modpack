Scriptname EnchantmentKnownChecker extends Quest
{
    This script manages enchantment checking via SKSE.
    It provides global functions to determine if a player has learned an enchantment.
}

; External SKSE function - checks if player knows a specific enchantment
; Returns true if the player has disenchanted an item with this enchantment
function bool CheckEnchantmentKnown(Enchantment akEnchantment) global native

; Wrapper function for UI to call - takes enchantment object and returns indicator string
function string GetEnchantmentIndicator(Enchantment akEnchantment) global
    if akEnchantment == none
        return ""
    endif
    
    if CheckEnchantmentKnown(akEnchantment)
        return " [K]"  ; "[K]" = Known. Modify to " (known)" or your preferred indicator
    endif
    
    return ""
endFunction

; Alternative: Get enchantment from an item and check it
function string GetItemEnchantmentIndicator(Form akItem) global
    if akItem == none
        return ""
    endif
    
    Enchantment itemEnchant = akItem as Enchantment
    if itemEnchant != none
        return GetEnchantmentIndicator(itemEnchant)
    endif
    
    return ""
endFunction

; For list items, this retrieves the enchantment and returns indicator
; Used by ActionScript to dynamically update item names in inventory
function string GetItemDisplayName(Form akItem) global
    if akItem == none
        return ""
    endif
    
    string baseName = akItem.GetName()
    string indicator = GetItemEnchantmentIndicator(akItem)
    
    return baseName + indicator
endFunction

; Event callback - you can hook this into item equip/unequip for real-time updates
event OnInit()
    ; Initialize any persistent data if needed
    ; This quest should be a persistent quest in your mod
endEvent
