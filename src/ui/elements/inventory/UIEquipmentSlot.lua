---
-- @module UIEquipmentSlot
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UIElement = require( 'src.ui.elements.UIElement' )
local UIBackground = require( 'src.ui.elements.UIBackground' )
local UILabel = require( 'src.ui.elements.UILabel' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIEquipmentSlot = UIElement:subclass( 'UIElement' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

local function updateBackground( self )
    if self.highlight then
        self.background:setColor( 'ui_equipment_highlight' )
    elseif self:isMouseOver() then
        self.background:setColor( 'ui_equipment_mouseover' )
    else
        self.background:setColor( 'sys_background' )
    end
end

local function updateLabel( self )
    if self.slot:containsItem() then
        self.label:setText( self.slot:getItem():getID() )
        self.label:setColor( 'ui_equipment_item' )
    else
        self.label:setText( self.slot:getID() )
        self.label:setColor( 'ui_equipment_empty' )
        self.label:setUpper( true )
    end
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Creates a new UIEquipmentList instance.
--
function UIEquipmentSlot:initialize( px, py, x, y, w, h, slot )
    UIElement.initialize( self, px, py, x, y, w, h )

    self.slot = slot
    self.background = UIBackground( self.ax, self.ay, 0, 0, self.w, self.h )
    self:addChild( self.background )

    self.label = UILabel( self.ax, self.ay, 0, 0, self.w, self.h )
    self:addChild( self.label )
end

function UIEquipmentSlot:draw()
    updateBackground( self )
    self.background:draw()

    updateLabel( self )
    self.label:draw()
end

function UIEquipmentSlot:getSlot()
    return self.slot
end

function UIEquipmentSlot:matchesType( item )
    if not item then
        self.highlight = false
        return
    end
    self.highlight = item:isSameType( self.slot:getItemType(), self.slot:getSubType() )
end

return UIEquipmentSlot
