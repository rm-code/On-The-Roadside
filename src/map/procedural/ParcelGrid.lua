---
-- @module ParcelGrid
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local Parcel = require( 'src.map.procedural.Parcel' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ParcelGrid = Class( 'ParcelGrid' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local DIRECTION = require( 'src.constants.DIRECTION' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Creates an empty parcel grid.
-- @tparam number w The parcel grid's width.
-- @tparam number h The parcel grid's height.
-- @tparam table    The new parcel grid.
--
local function createGrid( w, h )
    local parcels = {}
    for x = 0, w-1 do
        for y = 0, h-1 do
            parcels[x] = parcels[x] or {}
            parcels[x][y] = Parcel( 'empty' )
        end
    end
    return parcels
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Initializes the ParcelGrid.
-- @tparam number w The parcel grid's width.
-- @tparam number h The parcel grid's height.
--
function ParcelGrid:initialize( w, h )
    self.parcels = createGrid( w, h )
end

---
-- Adds a prefab to the ParcelGrid.
-- @tparam number x    The prefab's position on the grid along the x-axis.
-- @tparam number y    The prefab's position on the grid along the y-axis.
-- @tparam number w    The prefab's width.
-- @tparam number h    The prefab's height.
-- @tparam string type The prefab's type.
--
function ParcelGrid:addPrefab( x, y, w, h, type )
    for px = 0, w-1 do
        for py = 0, h-1 do
            self.parcels[px+x][py+y]:setType( type )
        end
    end
end

---
-- Gives each parcel in the grid a reference to its neighbours.
--
function ParcelGrid:createNeighbours()
    for x = 0, #self.parcels do
        for y = 0, #self.parcels[x] do
            local neighbours = {}

            neighbours[DIRECTION.NORTH]      = self:getParcelAt( x    , y - 1 ) or false
            neighbours[DIRECTION.SOUTH]      = self:getParcelAt( x    , y + 1 ) or false
            neighbours[DIRECTION.NORTH_EAST] = self:getParcelAt( x + 1, y - 1 ) or false
            neighbours[DIRECTION.NORTH_WEST] = self:getParcelAt( x - 1, y - 1 ) or false
            neighbours[DIRECTION.SOUTH_EAST] = self:getParcelAt( x + 1, y + 1 ) or false
            neighbours[DIRECTION.SOUTH_WEST] = self:getParcelAt( x - 1, y + 1 ) or false
            neighbours[DIRECTION.EAST]       = self:getParcelAt( x + 1, y     ) or false
            neighbours[DIRECTION.WEST]       = self:getParcelAt( x - 1, y     ) or false

            self.parcels[x][y]:setNeighbours( neighbours )
        end
    end
end

---
-- Returns the Parcel at the given coordinates.
-- @tparam  number x The position along the x-axis.
-- @tparam  number y The position along the y-axis.
-- @treturn Parcel   The Parcel at the given position.
--
function ParcelGrid:getParcelAt( x, y )
    return self.parcels[x] and self.parcels[x][y]
end

---
-- Iterates over all tiles and performs the callback function on them.
-- @param callback (function) The operation to perform on each tile.
--
function ParcelGrid:iterate( callback )
    for x = 0, #self.parcels do
        for y = 0, #self.parcels[x] do
            callback( self.parcels[x][y], x, y )
        end
    end
end

return ParcelGrid
