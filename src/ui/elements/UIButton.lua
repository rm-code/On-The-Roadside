---
-- @module UIButton
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UIElement = require( 'src.ui.elements.UIElement' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIButton = UIElement:subclass( 'UIButton' )

-- ------------------------------------------------
-- CONSTANTS
-- ------------------------------------------------

local COLORS = {}
COLORS.HOT = 'ui_button_hot'
COLORS.FOCUS = 'ui_button_focus'
COLORS.DEFAULT = 'ui_button'

COLORS.INACTIVE_HOT = 'ui_button_inactive_hot'
COLORS.INACTIVE_FOCUS = 'ui_button_inactive_focus'
COLORS.INACTIVE_DEFAULT = 'ui_button_inactive'

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

local function selectColor( self )
    if self.active then
        if love.mouse.isVisible() and self:isMouseOver() then
            return self.colors.HOT
        elseif self:hasFocus() then
            return self.colors.FOCUS
        end
        return self.colors.DEFAULT
    elseif not self.active then
        if love.mouse.isVisible() and self:isMouseOver() then
            return self.colors.INACTIVE_HOT
        elseif self:hasFocus() then
            return self.colors.INACTIVE_FOCUS
        end
        return self.colors.INACTIVE_DEFAULT
    end
end

local function drawIcon( px, py, icon, iconColorID )
    if not icon then
        return
    end

    if iconColorID then
        TexturePacks.setColor( iconColorID )
    end

    love.graphics.draw( TexturePacks.getTileset():getSpritesheet(), icon, px, py )
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function UIButton:initialize( px, py, x, y, w, h, callback, text, alignMode )
    UIElement.initialize( self, px, py, x, y, w, h )

    self.callback = callback
    self.text = text
    self.alignMode = alignMode or 'center'
    self.active = true

    self.colors = COLORS
end

function UIButton:draw()
    local tw, th = TexturePacks.getTileDimensions()

    TexturePacks.setColor( selectColor( self ))

    -- Draw text.
    if self.text then
        -- If we have an icon we start the text with an offset to the right.
        if self.icon then
            local x = self.ax + 2
            local w = TexturePacks.getFont():align( self.alignMode, self.text, (self.w-2) * tw )
            love.graphics.print( self.text, x * tw + w, self.ay * th )
        else
            local w = TexturePacks.getFont():align( self.alignMode, self.text, self.w * tw )
            love.graphics.print( self.text, self.ax * tw + w, self.ay * th )
        end
    end

    drawIcon( self.ax * tw, self.ay * th, self.icon, self.iconColorID )

    TexturePacks.resetColor()
end

function UIButton:activate()
    self.callback()
end

function UIButton:command( cmd )
    if cmd == 'activate' then
        self:activate()
    end
end

function UIButton:mousecommand( cmd )
    self:command( cmd )
end

-- ------------------------------------------------
-- Setters
-- ------------------------------------------------

function UIButton:setText( text, alignMode )
    self.text = text
    self.alignMode = alignMode
end

function UIButton:setColors( table )
    self.colors = table
end

function UIButton:setDefaultColors()
    self.colors = COLORS
end

function UIButton:setIcon( id, alt )
    self.icon = TexturePacks.getSprite( id, alt )
end

function UIButton:setIconColorID( color )
    self.iconColorID = color
end

function UIButton:setActive( active )
    self.active = active
end

return UIButton
