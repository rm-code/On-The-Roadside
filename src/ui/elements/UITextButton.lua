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

local UITextButton = UIElement:subclass( 'UITextButton' )

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UITextButton:initialize( ox, oy, rx, ry, w, h, text, callback, alignMode, active )
    UIElement.initialize( self, ox, oy, rx, ry, w, h )
    self.text = text
    self.callback = callback
    self.alignMode = alignMode or 'center'
    self.active = active or true
end

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

local function selectColor( self )
    if self.active then
        if love.mouse.isVisible() and self:isMouseOver() then
            return 'ui_button_hot'
        elseif self:hasFocus() then
            return 'ui_button_focus'
        end
        return 'ui_button'
    elseif not self.active then
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

function UITextButton:draw()
    local tw, th = TexturePacks.getTileDimensions()
    TexturePacks.setColor( selectColor( self ))
    love.graphics.print( self.text, self.ax * tw + TexturePacks.getFont():align( self.alignMode, self.text, self.w * tw ), self.ay * th )
    TexturePacks.resetColor()
end

function UITextButton:activate()
    if not self.active then
        return
    end
    self.callback()
end

function UITextButton:command( cmd )
    if cmd == 'activate' then
        self:activate()
    end
end

function UITextButton:mousereleased( _, _, _, _ )
    if self:isMouseOver() then
        self:activate()
    end
end

function UITextButton:setActive( nactive )
    self.active = nactive
end

return UITextButton
