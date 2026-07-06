;=====================================================
; EnchantmentIndicator_Global.psc
; Main global script for enchantment knowledge checking
; This script provides the core functionality to check if an enchantment is known
;=====================================================

scriptName EnchantmentIndicator_Global

; Native SKSE function to check if enchantment is known
; This requires SKSE to be installed
; Returns true if the player's character has learned the enchantment (disenchanted it)
native bool IsEnchantmentKnown(Enchantment akEnchant) global

; Alternative method if SKSE native isn't available:
; Uses fallback technique of checking ingredient knowledge
; Enchantments are typically "known" if you've disenchanted them before

function OnInit()
    ; This script runs automatically when the mod is initialized
    ; No special setup required - it's purely a utility script
endFunction

; Main function to check if an item's enchantment is known
; Called from UI/ActionScript code
bool function IsItemEnchantmentKnown(Form akItem)
    if akItem == none
        return false
    endif
    
    ; Cast to appropriate type
    if akItem as Weapon
        Weapon weap = akItem as Weapon
        Enchantment enchant = weap.GetEnchantment()
        if enchant != none
            return IsEnchantmentKnown(enchant)
        endif
    elseif akItem as Armor
        Armor arm = akItem as Armor
        Enchantment enchant = arm.GetEnchantment()
        if enchant != none
            return IsEnchantmentKnown(enchant)
        endif
    endif
    
    return false
endFunction

; Get the enchantment from an item (helper function)
Enchantment function GetItemEnchantment(Form akItem)
    if akItem == none
        return none
    endif
    
    if akItem as Weapon
        Weapon weap = akItem as Weapon
        return weap.GetEnchantment()
    elseif akItem as Armor
        Armor arm = akItem as Armor
        return arm.GetEnchantment()
    endif
    
    return none
endFunction

; Get enchantment name for display purposes
string function GetEnchantmentName(Enchantment akEnchant)
    if akEnchant != none
        return akEnchant.GetName()
    endif
    return ""
endFunction

; Get cost/magnitude info about the enchantment (optional)
int function GetEnchantmentCost(Enchantment akEnchant)
    if akEnchant != none
        return akEnchant.GetGoldValue()
    endif
    return 0
endFunction
