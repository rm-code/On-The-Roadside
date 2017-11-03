---
-- This class creates a button with a text label.
-- @module UITextButton
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UIElement = require( 'src.ui.elements.UIElement' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UITextButton = {}

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UITextButton.new( px, py, x, y, w, h )
    local self = UIElement.new( px, py, x, y, w, h ):addInstance( 'UITextButton' )

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local text
    local callback
    local alignMode

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    local function selectColor()
        if self:isMouseOver() then
            return 'ui_button_hot'
        elseif self:hasFocus() then
            return 'ui_button_focus'
        end
        return 'ui_button'
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init( ntext, ncallback, nalignMode )
        text = ntext
        callback = ncallback
        alignMode = nalignMode or 'center'
    end

    function self:draw()
        local tw, th = TexturePacks.getTileDimensions()
        TexturePacks.setColor( selectColor() )
        love.graphics.print( text, self.ax * tw + TexturePacks.getFont():align( alignMode, text, self.w * tw ), self.ay * th )
        TexturePacks.resetColor()
    end

    function self:activate()
        callback()
    end

    function self:keypressed( _, scancode )
        if scancode == 'return' then
            self:activate()
        end
    end

    function self:mousereleased( _, _, _, _ )
        if self:isMouseOver() then
            self:activate()
        end
    end

    return self
end

return UITextButton
