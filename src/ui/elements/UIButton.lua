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

function UIButton:initialize( px, py, x, y, w, h, tileID, ncallback )
    UIElement.initialize( self, px, py, x, y, w, h )

    self.icon = TexturePacks.getSprite( tileID )
    self.callback = ncallback
end

function UIButton:draw()
    local tw, th = TexturePacks.getTileDimensions()
    TexturePacks.setColor( self:isMouseOver() and 'ui_button_hot' or 'ui_button' )
    love.graphics.draw( TexturePacks.getTileset():getSpritesheet(), self.icon, self.ax * tw, self.ay * th )
    TexturePacks.resetColor()
end

function UIButton:activate()
    self.callback()
end

return UIButton
