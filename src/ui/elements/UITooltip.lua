---
-- @module UITooltip
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UIElement = require( 'src.ui.elements.UIElement' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UITooltip = UIElement:subclass( 'UITooltip' )

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UITooltip:initialize()
    UIElement.initialize( self, 0, 0, 0, 0, 0, 1 )

    self.tileset = TexturePacks.getTileset()
    self.tw, self.th = TexturePacks.getTileDimensions()

    self.iconPointer = 'ui_tooltip_pointer'
end

function UITooltip:draw()
    TexturePacks.setColor( 'tile_empty' )
    love.graphics.rectangle( 'fill', (self.ax + self.offsetX) * self.tw, self.ay * self.th, self.tw, self.th )
    TexturePacks.setColor( 'ui_tooltip_bg' )
    love.graphics.rectangle( 'fill', (self.ax + self.textOffsetX) * self.tw, self.ay * self.th, self.w * self.tw, self.th )

    -- Draw pointer
    love.graphics.draw( self.tileset:getSpritesheet(), self.tileset:getSprite( self.iconPointer ), (self.ax + self.offsetX) * self.tw, self.ay * self.th )

    -- Draw text
    TexturePacks.setColor( 'ui_tooltip_text' )
    love.graphics.printf( self.text, (self.ax + self.textOffsetX) * self.tw, self.ay * self.th, self.w * self.tw, 'center' )
    TexturePacks.resetColor()
end

function UITooltip:setText( text )
    self.text = text
    self.w = math.ceil( text:len() * 0.5 ) + 1
end

function UITooltip:setDirection( direction )
    self.direction = direction
    if direction == 'right' then
        self.offsetX = 1
        self.textOffsetX = 2 * self.offsetX
    else
        self.offsetX = -1
        self.textOffsetX = -1 - self.w
    end
end

return UITooltip
