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

function Parcel.new()
    local self = Object.new():addInstance( 'Parcel' )

    local occupied
    local neighbours

    ---
    -- Checks if the parcel is valid for spawning a prefab's parcel.
    -- @treturn boolean True if it is valid.
    --
    function self:isValid()
        -- Parcel already contains a prefab parcel.
        if self:isOccupied() then
            return false
        end

        -- Check the adjacent parcels.
        for _, neighbour in pairs( neighbours ) do
            -- If this parcel doesn't have a neighbour it is on the map border
            -- and therefore invalid.
            if not neighbour then
                return false
            end

            -- If any of the adjacent parcels contain a prefab part we cancel
            -- because parcels should have one parcel distance between them.
            if neighbour:isOccupied() then
                return false
            end
        end

        return true
    end

    function self:isOccupied()
        return occupied
    end

    function self:setOccupied( noccupied )
        occupied = noccupied
    end

    function self:setNeighbours( nneighbours )
        neighbours = nneighbours
    end

    function self:getNeighbours()
        return neighbours
    end

    return self
end

return Parcel
