;=====================================================
; BarterMenuEI.as (ActionScript 2)
; Custom panel for barter menu enchantment indicators
; Extends the SkyUI barter menu to show enchantment knowledge
;=====================================================

import gfx.core.UIComponent;
import skyui.util.GlobalFunctions;

class BarterMenuEI extends UIComponent
{
    // References to barter menu UI elements
    private var playerListMC:MovieClip; // Left side - player inventory
    private var merchantListMC:MovieClip; // Right side - merchant inventory
    
    // Configuration
    private var indicatorText:String = " [K]";
    private var knownColor:Number = 0x90EE90; // Light green for known
    private var unknownColor:Number = 0xFF6347; // Tomato red for unknown
    
    public function BarterMenuEI()
    {
        super();
    }
    
    public function onLoad():Void
    {
        super.onLoad();
        SetupBarterMenuHooks();
    }
    
    // Setup hooks for both sides of barter menu
    private function SetupBarterMenuHooks():Void
    {
        // Hook into player inventory list
        if (playerListMC != undefined)
        {
            playerListMC.onItemRendered = Delegate.create(this, OnPlayerItemRendered);
        }
        
        // Hook into merchant inventory list
        if (merchantListMC != undefined)
        {
            merchantListMC.onItemRendered = Delegate.create(this, OnMerchantItemRendered);
        }
    }
    
    // Callback when player inventory item is rendered
    private function OnPlayerItemRendered(renderer:MovieClip, itemData:Object):Void
    {
        ProcessItemForEnchantment(renderer, itemData, true);
    }
    
    // Callback when merchant inventory item is rendered
    private function OnMerchantItemRendered(renderer:MovieClip, itemData:Object):Void
    {
        ProcessItemForEnchantment(renderer, itemData, false);
    }
    
    // Main processing function for enchantment indicators
    private function ProcessItemForEnchantment(renderer:MovieClip, itemData:Object, isPlayerInventory:Boolean):Void
    {
        if (itemData == undefined || renderer == undefined)
            return;
        
        // Check if item is enchanted
        if (!itemData.enchanted)
            return;
        
        // Get text field
        var textField:TextField = renderer.text_mc;
        if (textField == undefined)
            return;
        
        // Query Papyrus for enchantment knowledge status
        var isKnown:Boolean = QueryEnchantmentKnowledge(itemData.formID);
        
        // Update display
        UpdateItemDisplay(textField, itemData, isKnown);
    }
    
    // Update item display with enchantment indicator
    private function UpdateItemDisplay(textField:TextField, itemData:Object, isKnown:Boolean):Void
    {
        var originalText:String = textField.text;
        var newText:String = originalText;
        var displayColor:Number;
        
        if (isKnown)
        {
            newText += indicatorText;
            displayColor = knownColor;
        }
        else
        {
            newText += " (?)";
            displayColor = unknownColor;
        }
        
        textField.text = newText;
        
        // Apply text formatting
        var fmt:TextFormat = new TextFormat();
        fmt.color = displayColor;
        fmt.bold = true;
        textField.setTextFormat(fmt);
    }
    
    // Query Papyrus to check if enchantment is known
    // This is called via SKSE callback mechanism
    private function QueryEnchantmentKnowledge(formID:Number):Boolean
    {
        // In actual implementation, this would use SKSE communication
        // to query the Papyrus script
        
        // Placeholder: Would be implemented via:
        // - SKSE plugin callback
        // - Shared memory/registry
        // - Or stored in item data from initial load
        
        return false; // Default: assume unknown
    }
    
    // Batch update enchantments (called from quest script)
    public function UpdateEnchantmentBatch(enchantDataArray:Array):Void
    {
        for (var i:Number = 0; i < enchantDataArray.length; i++)
        {
            var enchData:Object = enchantDataArray[i];
            // enchData should contain: { formID, isKnown, itemName, ... }
            
            // Find and update the corresponding renderer
            UpdateEnchantmentInList(playerListMC, enchData);
            UpdateEnchantmentInList(merchantListMC, enchData);
        }
    }
    
    // Helper to update enchantment in a specific list
    private function UpdateEnchantmentInList(listMC:MovieClip, enchData:Object):Void
    {
        if (listMC == undefined)
            return;
        
        // Iterate through visible items
        for (var i:Number = 0; i < listMC.numChildren; i++)
        {
            var renderer:MovieClip = listMC.getChildAt(i);
            var itemData:Object = renderer.data;
            
            if (itemData != undefined && itemData.formID == enchData.formID)
            {
                var textField:TextField = renderer.text_mc;
                if (textField != undefined)
                {
                    UpdateItemDisplay(textField, itemData, enchData.isKnown);
                }
            }
        }
    }
}
