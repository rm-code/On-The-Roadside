---
-- @module Brush
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Brush = Class( 'Brush' )

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Brush:setTemplate( template )
    self.template = template
end

function Brush:setLayer( layer )
    self.layer = layer
end

function Brush:setIcon( id, alt )
    self.icon = TexturePacks.getSprite( id, alt )
end

function Brush:setIconColorID( color )
    self.iconColorID = color
end

function Brush:getTemplate()
    return self.template
end

function Brush:getLayer()
    return self.layer
end

function Brush:getIcon()
    return self.icon
end

function Brush:getIconColorID()
    return self.iconColorID
end

return Brush
