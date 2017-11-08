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

local UIEquipmentSlot = {}

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- @tparam EquipmentSlot slot The equipment slot to use.
-- @tparam number        x    The x-offset at which to draw this ui-element.
-- @tparam number        y    The y-offset at which to draw this ui-element.
-- @tparam number        w    The width of this ui-element.
-- @tparam number        h    The height of this ui-element.
--
function UIEquipmentSlot.new( px, py, x, y, w, h )
    local self = UIElement.new( px, py, x, y, w, h ):addInstance( 'UIEquipmentSlot' )

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local background
    local label
    local slot
    local highlight

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    local function updateBackground()
        if highlight then
            background:setColor( 'ui_equipment_highlight' )
        elseif self:isMouseOver() then
            background:setColor( 'ui_equipment_mouseover' )
        else
            background:setColor( 'sys_background' )
        end
    end

    local function updateLabel()
        if slot:containsItem() then
            label:setText( slot:getItem():getID() )
            label:setColor( 'ui_equipment_item' )
        else
            label:setText( slot:getID() )
            label:setColor( 'ui_equipment_empty' )
            label:setUpper( true )
        end
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init( nslot )
        slot = nslot

        background = UIBackground.new( self.ax, self.ay, 0, 0, self.w, self.h )
        self:addChild( background )

        label = UILabel.new( self.ax, self.ay, 0, 0, self.w, self.h )
        self:addChild( label )
    end

    function self:draw()
        updateBackground()
        background:draw()

        updateLabel()
        label:draw()
    end

    function self:getSlot()
        return slot
    end

    function self:highlight( nitem )
        if not nitem then
            highlight = false
            return
        end
        highlight = nitem:isSameType( slot:getItemType(), slot:getSubType() )
    end

    return self
end

return UIEquipmentSlot
