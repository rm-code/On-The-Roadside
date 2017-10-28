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

local UILabel = {}

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UILabel.new( px, py, x, y, w, h, text, color )
    local self = UIElement.new( px, py, x, y, w, h ):addInstance( 'UILabel' )

    color = color or 'sys_reset'

    local tw, th = TexturePacks.getTileDimensions()

    function self:draw()
        TexturePacks.setColor( color )
        love.graphics.print( text, self.ax * tw, self.ay * th )
        TexturePacks.resetColor()
    end

    function self:setText( ntextID )
        text = Translator.getText( ntextID )
    end

    function self:setColor( ncolor )
        color = ncolor
    end

    function self:setUpper( nupper )
        text = nupper and string.upper( text ) or text
    end

    return self
end

return UILabel
