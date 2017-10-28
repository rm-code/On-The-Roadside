---
-- @module Label
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Object = require( 'src.Object' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Label = {}

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Label.new( text, color, align )
    local self = Object.new():addInstance( 'Label' )

    function self:draw( x, y, w, _ )
        TexturePacks.setColor( color )
        love.graphics.print( text, x + TexturePacks.getFont():align( align or 'left', text, w ), y )
        TexturePacks.resetColor()
    end

    return self
end

return Label
