---
-- @module MapObject
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Observable = require( 'src.util.Observable' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MapObject = Observable:subclass( 'MapObject' )

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function MapObject:initialize()
    Observable.initialize( self )
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

function MapObject:getX()
    return self.x
end

function MapObject:getY()
    return self.y
end

function MapObject:getPosition()
    return self.x, self.y
end

function MapObject:getMap()
    return self.map
end

function MapObject:getTile()
    return self.map:getTileAt( self.x, self.y )
end

function MapObject:getCharacter()
    return self.map:getCharacterAt( self.x, self.y )
end

function MapObject:hasCharacter()
    return self.map:getCharacterAt( self.x, self.y ) ~= nil
end

function MapObject:getWorldObject()
    return self.map:getWorldObjectAt( self.x, self.y )
end

function MapObject:hasWorldObject()
    return self.map:getWorldObjectAt( self.x, self.y ) ~= nil
end

function MapObject:getNeighbours()
    return self.map:getNeighbours( self.x, self.y, self )
end

function MapObject:getNeighbour( direction )
    return self.map:getNeighbour( self.x, self.y, self, direction )
end

-- ------------------------------------------------
-- Setters
-- ------------------------------------------------

function MapObject:setPosition( x, y )
    self.x, self.y = x, y
end

function MapObject:setMap( map )
    self.map = map
end

return MapObject
