---
-- @module ParcelGrid
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Object = require( 'src.Object' )
local Parcel = require( 'src.map.procedural.Parcel' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ParcelGrid = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local DIRECTION = require( 'src.constants.DIRECTION' )


-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function ParcelGrid.new()
    local self = Object.new():addInstance( 'ParcelGrid' )

    local parcels

    local function createGrid( w, h )
        local nparcels = {}
        for x = 0, w-1 do
            for y = 0, h-1 do
                nparcels[x] = nparcels[x] or {}
                nparcels[x][y] = Parcel.new( 'empty' )
            end
        end
        return nparcels
    end

    function self:init( w, h )
        parcels = createGrid( w, h )
    end

    function self:addParcels( x, y, w, h, type )
        for px = 0, w-1 do
            for py = 0, h-1 do
                parcels[px+x][py+y] = Parcel.new( type )
            end
        end
    end

    ---
    -- Gives each parcel in the grid a reference to its neighbours.
    --
    function self:createNeighbours()
        for x = 0, #parcels do
            for y = 0, #parcels[x] do
                local neighbours = {}

                neighbours[DIRECTION.NORTH]      = self:getParcelAt( x    , y - 1 ) or false
                neighbours[DIRECTION.SOUTH]      = self:getParcelAt( x    , y + 1 ) or false
                neighbours[DIRECTION.NORTH_EAST] = self:getParcelAt( x + 1, y - 1 ) or false
                neighbours[DIRECTION.NORTH_WEST] = self:getParcelAt( x - 1, y - 1 ) or false
                neighbours[DIRECTION.SOUTH_EAST] = self:getParcelAt( x + 1, y + 1 ) or false
                neighbours[DIRECTION.SOUTH_WEST] = self:getParcelAt( x - 1, y + 1 ) or false
                neighbours[DIRECTION.EAST]       = self:getParcelAt( x + 1, y     ) or false
                neighbours[DIRECTION.WEST]       = self:getParcelAt( x - 1, y     ) or false

                parcels[x][y]:setNeighbours( neighbours )
            end
        end
    end

    ---
    -- Returns the Parcel at the given coordinates.
    -- @tparam  number x The position along the x-axis.
    -- @tparam  number y The position along the y-axis.
    -- @treturn Parcel   The Parcel at the given position.
    --
    function self:getParcelAt( x, y )
        return parcels[x] and parcels[x][y]
    end

    ---
    -- Iterates over all tiles and performs the callback function on them.
    -- @param callback (function) The operation to perform on each tile.
    --
    function self:iterate( callback )
        for x = 0, #parcels do
            for y = 0, #parcels[x] do
                callback( parcels[x][y], x, y )
            end
        end
    end

    return self
end

return ParcelGrid
