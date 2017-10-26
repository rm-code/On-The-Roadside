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

local UIButton = {}

function UIButton.new( px, py, x, y, w, h )
    local self = UIElement.new( px, py, x, y, w, h ):addInstance( 'UIButton' )

    local tileset
    local icon
    local callback

    function self:init( tileID, ncallback )
        tileset = TexturePacks.getTileset()
        icon = TexturePacks.getSprite( tileID )

        callback = ncallback
    end

    function self:draw()
        local tw, th = TexturePacks.getTileDimensions()
        TexturePacks.setColor( self:isMouseOver() and 'ui_button_hot' or 'ui_button' )
        love.graphics.draw( tileset:getSpritesheet(), icon, self.ax * tw, self.ay * th )
        TexturePacks.resetColor()
    end

    function self:activate()
        callback()
    end

    return self
end

return UIButton
