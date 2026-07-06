;=====================================================
; InventoryListPanelEI.as (ActionScript 2)
; Custom extension/modification for SkyUI inventory list
; Displays "(known)" indicator for enchantments player has learned
;
; This is meant to be compiled and either:
; 1. Injected into the existing SkyUI inventorylist.swf
; 2. Used as a separate panel that overlays the original
;=====================================================

import gfx.core.UIComponent;
import skyui.util.GlobalFunctions;
import skyui.util.Translator;
import skyui.components.list.BasicList;
import skyui.components.list.ListItemRenderer;

class InventoryListPanelEI extends BasicList
{
    // Configuration
    private var enchantmentIndicatorColor:Number = 0xFFD700; // Gold color for "known" indicator
    private var enchantmentIndicatorText:String = " [K]"; // Text indicator, or use icon
    
    public function InventoryListPanelEI()
    {
        super();
    }
    
    // Override the item renderer to add enchantment indicators
    public function draw(aItemData:Object, aIndex:Number):Void
    {
        // Call parent draw to render normal item
        super.draw(aItemData, aIndex);
        
        // Add enchantment indicator if applicable
        AddEnchantmentIndicator(aItemData, aIndex);
    }
    
    // Function to add the "(known)" indicator to an item
    private function AddEnchantmentIndicator(itemData:Object, itemIndex:Number):Void
    {
        if (itemData == undefined || itemData == null)
            return;
        
        // Get the text field that displays the item name
        var itemRenderer:ListItemRenderer = ListItemRenderer(GetItemRenderer(itemIndex));
        if (itemRenderer == undefined)
            return;
        
        var itemNameTextField:TextField = itemRenderer.GetTextComponent();
        if (itemNameTextField == undefined)
            return;
        
        // Check if item is enchanted
        if (!itemData.hasOwnProperty("enchanted") || !itemData.enchanted)
            return;
        
        // Call SKSE plugin to check if enchantment is known
        var isKnown:Boolean = CheckEnchantmentKnown(itemData);
        
        if (isKnown)
        {
            // Modify the displayed text
            itemNameTextField.text += enchantmentIndicatorText;
            
            // Optional: Change text color
            var textFormat:TextFormat = itemNameTextField.getTextFormat();
            textFormat.color = enchantmentIndicatorColor;
            itemNameTextField.setTextFormat(textFormat);
        }
    }
    
    // Call external SKSE function to check if enchantment is known
    // This requires SKSE and the enchantment indicator SKSE plugin
    private function CheckEnchantmentKnown(itemData:Object):Boolean
    {
        // This is a native call to SKSE
        // The actual implementation depends on your SKSE plugin
        
        // Fallback implementation if direct SKSE call isn't available:
        // You would need to implement this through Papyrus callbacks
        
        if (itemData.hasOwnProperty("isEnchantmentKnown"))
        {
            return itemData.isEnchantmentKnown;
        }
        
        return false;
    }
    
    // Alternative method: Use Papyrus to set enchantment knowledge property
    // This function would be called by Papyrus when updating item data
    public function SetItemEnchantmentStatus(itemIndex:Number, isKnown:Boolean):Void
    {
        var itemData:Object = GetItemData(itemIndex);
        if (itemData != undefined)
        {
            itemData.isEnchantmentKnown = isKnown;
            InvalidateItem(itemIndex);
        }
    }
}
