;=====================================================
; EnchantmentIndicator_Quest.psc
; Quest script that manages the enchantment indicator system
; This runs on a persistent quest to handle registrations and callbacks
;=====================================================

scriptName EnchantmentIndicator_Quest extends Quest

; Reference to the global utility script
import EnchantmentIndicator_Global

; Quest initialization
event OnInit()
    ; Optional: Log mod initialization
    Debug.MessageBox("Enchantment Indicator Mod loaded!")
    
    ; The quest will remain active and can receive events
    self.SetActive(true)
    
    ; Optional: Set up any menu registration if using SkyUI's framework
    RegisterMenus()
endEvent

; Register this mod's custom menu handling with SkyUI (if using SkyUI framework)
function RegisterMenus()
    ; If using SkyUI's menu framework, you would register here
    ; This is optional and depends on your implementation approach
    
    ; Example if using SkyUI's callback system:
    ; RegisterForMenuOpenCloseEvent("InventoryMenu")
    ; RegisterForMenuOpenCloseEvent("BarterMenu")
endFunction

; Optional: Handle menu events if using SkyUI framework
event OnMenuOpenCloseEvent(string asMenuName, bool abOpening)
    if abOpening
        if asMenuName == "InventoryMenu" || asMenuName == "BarterMenu" || asMenuName == "ContainerMenu"
            ; Menu opened - you might want to broadcast to ActionScript here
            ; This is handled primarily by the .swf modifications
        endif
    endif
endEvent

; Utility: Check if an item in player inventory is enchanted and known
function DebugCheckPlayerInventory()
    ; This is a debugging function to test enchantment checking
    int itemCount = Game.GetPlayer().GetItemCount(none)
    
    int i = 0
    while i < itemCount
        Form itemForm = Game.GetPlayer().GetNthForm(i)
        Enchantment ench = GetItemEnchantment(itemForm)
        
        if ench != none
            bool isKnown = IsEnchantmentKnown(ench)
            string knownStr = "UNKNOWN"
            if isKnown
                knownStr = "KNOWN"
            endif
            
            Debug.Trace("[EI] Item: " + itemForm.GetName() + " | Enchant: " + ench.GetName() + " | Status: " + knownStr)
        endif
        
        i += 1
    endwhile
endFunction
