;=====================================================
; EnchantmentIndicator_SWFUI.as (ActionScript 2)
; Standalone custom menu component for enchantment indicators
; Can be injected into SkyUI or used with custom menu framework
;=====================================================

import gfx.core.UIComponent;
import gfx.utils.Delegate;
import skyui.components.list.BasicList;

class EnchantmentIndicator_SWFUI extends UIComponent
{
    // UI Elements
    private var itemList:BasicList;
    private var indicatorSymbol:String = "[K]";
    private var knownEnchantColor:Number = 0xFFD700; // Gold
    private var unknownEnchantColor:Number = 0xFFFFFF; // White
    
    // Overlay layer for indicators
    private var indicatorLayer:MovieClip;
    
    public function EnchantmentIndicator_SWFUI()
    {
        super();
    }
    
    public function onLoad():Void
    {
        super.onLoad();
        InitializeIndicatorLayer();
    }
    
    // Create overlay layer for enchantment indicators
    private function InitializeIndicatorLayer():Void
    {
        indicatorLayer = CreateEmptyMovieClip("indicator_layer_mc", GetNextHighestDepth());
        indicatorLayer._alpha = 100;
    }
    
    // Main function: Update item with enchantment indicator
    public function UpdateItemWithIndicator(itemIndex:Number, itemName:String, 
                                          isEnchanted:Boolean, isKnown:Boolean):Void
    {
        if (!isEnchanted)
            return;
        
        var newName:String = itemName;
        var textColor:Number;
        
        if (isKnown)
        {
            newName += " " + indicatorSymbol;
            textColor = knownEnchantColor;
        }
        else
        {
            newName += " (?)"; // Unknown enchant marker
            textColor = unknownEnchantColor;
        }
        
        // Update the list item display
        UpdateListItemDisplay(itemIndex, newName, textColor);
    }
    
    // Update the actual list item on screen
    private function UpdateListItemDisplay(itemIndex:Number, newText:String, color:Number):Void
    {
        var renderer:MovieClip = itemList.GetItemRenderer(itemIndex);
        
        if (renderer != undefined)
        {
            if (renderer.text_mc != undefined)
            {
                renderer.text_mc.text = newText;
                
                // Apply color format
                var fmt:TextFormat = new TextFormat();
                fmt.color = color;
                renderer.text_mc.setTextFormat(fmt);
            }
        }
    }
    
    // Callback from Papyrus script with enchantment status
    public function OnEnchantmentStatusUpdate(itemFormID:Number, isKnown:Boolean):Void
    {
        // This would be called from Papyrus with item data
        // Update the visual representation accordingly
        
        // Iterate through list to find matching item
        for (var i:Number = 0; i < itemList.GetLength(); i++)
        {
            var itemData:Object = itemList.GetEntryObject(i);
            
            if (itemData.formID == itemFormID)
            {
                // Found the matching item, update it
                var isEnchanted:Boolean = itemData.enchanted;
                UpdateItemWithIndicator(i, itemData.name, isEnchanted, isKnown);
                break;
            }
        }
    }
    
    // Optional: Batch update multiple items (more efficient)
    public function BatchUpdateEnchantments(enchantmentData:Array):Void
    {
        for (var i:Number = 0; i < enchantmentData.length; i++)
        {
            var data:Object = enchantmentData[i];
            OnEnchantmentStatusUpdate(data.formID, data.isKnown);
        }
    }
    
    // Visual indicator using icons instead of text
    // Requires icon assets in your mod
    public function CreateIconIndicator(isKnown:Boolean):MovieClip
    {
        var icon:MovieClip = indicatorLayer.createEmptyMovieClip("icon_mc", indicatorLayer.getNextHighestDepth());
        
        if (isKnown)
        {
            // Draw a checkmark or use external image
            DrawCheckmark(icon, knownEnchantColor);
        }
        else
        {
            // Draw a question mark
            DrawQuestionMark(icon, unknownEnchantColor);
        }
        
        return icon;
    }
    
    // Draw checkmark icon
    private function DrawCheckmark(targetMC:MovieClip, color:Number):Void
    {
        targetMC.lineStyle(2, color, 100);
        targetMC.moveTo(0, 8);
        targetMC.lineTo(4, 12);
        targetMC.lineTo(12, 2);
    }
    
    // Draw question mark icon
    private function DrawQuestionMark(targetMC:MovieClip, color:Number):Void
    {
        targetMC.lineStyle(1, color, 100);
        
        // Draw circle
        targetMC.drawCircle(7, 7, 6);
        
        // Draw question mark (simplified)
        targetMC.moveTo(7, 3);
        targetMC.lineTo(7, 5);
        targetMC.moveTo(7, 10);
        targetMC.lineTo(7, 12);
    }
}
