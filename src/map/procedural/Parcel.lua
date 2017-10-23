---
-- Represents a parcel inside of the procedural maps parcel grid and can be
-- used to check for valid spawning points.
-- @module Parcel
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Object = require( 'src.Object' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Parcel = {}

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Parcel.new( type )
    local self = Object.new():addInstance( 'Parcel' )

    local neighbours

    function self:setNeighbours( nneighbours )
        neighbours = nneighbours
    end

    function self:getType()
        return type
    end

    function self:getNeighbourCount()
        local count = 0
        for _, neighbour in pairs( neighbours ) do
            if neighbour and neighbour:getType() == type then
                count = count + 1
            end
        end
        return count
    end

    return self
end

return Parcel
