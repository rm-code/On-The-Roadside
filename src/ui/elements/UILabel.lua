---
-- @module UILabel
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UIElement = require( 'src.ui.elements.UIElement' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local Translator = require( 'src.util.Translator' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UILabel = UIElement:subclass( 'UILabel' )

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UILabel:initialize( px, py, x, y, w, h, text, color, align )
    UIElement.initialize( self, px, py, x, y, w, h )

    self.text = text
    self.color = color or 'sys_reset'
    self.align = align or 'left'
end

function UILabel:draw()
    local tw, th = TexturePacks.getTileDimensions()

    TexturePacks.setColor( self.color )
    love.graphics.printf( self.text, self.ax * tw, self.ay * th, self.w * tw, self.align )
    TexturePacks.resetColor()
end

function UILabel:setText( ntextID )
    self.text = Translator.getText( ntextID )
end

function UILabel:setColor( ncolor )
    self.color = ncolor
end

function UILabel:setUpper( nupper )
    self.text = nupper and string.upper( self.text ) or self.text
end

return UILabel
