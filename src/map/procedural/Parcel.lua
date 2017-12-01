---
-- Represents a parcel inside of the procedural maps parcel grid and can be
-- used to check for valid spawning points.
-- @module Parcel
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Parcel = Class( 'Parcel' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Initializes the Parcel instance.
-- @tparam string type The type of Parcel to spawn.
--
function Parcel:initialize( type )
    self.type = type
end

---
-- Counts the neighbours of the same type around this parcel.
-- @treturn number The number of neighbours with the same type.
--
function Parcel:countNeighbours()
    local count = 0
    for _, neighbour in pairs( self.neighbours ) do
        if neighbour and neighbour:getType() == self.type then
            count = count + 1
        end
    end
    return count
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

---
-- Returns this parcel's type.
-- @treturn string The parcel's type.
--
function Parcel:getType()
    return self.type
end

-- ------------------------------------------------
-- Setters
-- ------------------------------------------------

---
-- Sets the neighbours for this parcel.
-- @tparam table neighbours The neighbouring parcels.
--
function Parcel:setNeighbours( neighbours )
    self.neighbours = neighbours
end

---
-- Sets the type of this parcel.
-- @tparam string type The new type to use.
--
function Parcel:setType( type )
    self.type = type
end

return Parcel
