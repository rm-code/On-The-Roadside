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
    local active

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    local function selectColor()
        if active then
            if love.mouse.isVisible() and self:isMouseOver() then
                return 'ui_button_hot'
            elseif self:hasFocus() then
                return 'ui_button_focus'
            end
            return 'ui_button'
        elseif not active then
            if love.mouse.isVisible() and self:isMouseOver() then
                return 'ui_button_inactive_hot'
            elseif self:hasFocus() then
                return 'ui_button_inactive_focus'
            end
            return 'ui_button_inactive'
        end
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init( ntext, ncallback, nalignMode )
        text = ntext
        callback = ncallback
        alignMode = nalignMode or 'center'
        active = true
    end

    function self:draw()
        local tw, th = TexturePacks.getTileDimensions()
        TexturePacks.setColor( selectColor() )
        love.graphics.print( text, self.ax * tw + TexturePacks.getFont():align( alignMode, text, self.w * tw ), self.ay * th )
        TexturePacks.resetColor()
    end

    function self:activate()
        if not active then
            return
        end
        callback()
    end

    function self:command( cmd )
        if cmd == 'activate' then
            self:activate()
        end
    end

    function self:mousereleased( _, _, _, _ )
        if self:isMouseOver() then
            self:activate()
        end
    end

    function self:setActive( nactive )
        active = nactive
    end

    return self
end

return UITextButton
