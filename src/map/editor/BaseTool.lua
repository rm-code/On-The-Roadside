---
-- @module BaseTool
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BaseTool = Class( 'BaseTool' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function BaseTool:initialize( id )
    self.id = id
    self.size = 1
    self.active = false
end

function BaseTool:increaseSize()
    self.size = self.size + 1
end

function BaseTool:decreaseSize()
    self.size = self.size - 1
end

function BaseTool:getID()
    return self.id
end

function BaseTool:setActive( nactive )
    self.active = nactive
end

function BaseTool:setPosition( x, y )
    self.x, self.y = x, y
end

function BaseTool:setTemplate( template )
    self.template = template
end

function BaseTool:setLayer( layer )
    self.layer = layer
end

function BaseTool:setIcon( icon )
    self.icon = icon
end

function BaseTool:setIconColorID( color )
    self.iconColorID = color
end

return BaseTool
