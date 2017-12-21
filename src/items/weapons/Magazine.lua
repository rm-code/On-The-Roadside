---
-- This module is used to keep track of the rounds currently loaded into a
-- reloadable weapon.
-- @module Magazine
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local Ammunition = require( 'src.items.weapons.Ammunition' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Magazine = Class( 'Magazine' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Initializes a new instance of the Magazine class.
-- @tparam string caliber  The caliber type the magazine can store.
-- @tparam number capacity The maximum amount of rounds this magazine can hold.
--
function Magazine:initialize( caliber, capacity )
    self.caliber = caliber
    self.capacity = capacity

    self.rounds = {}
end

---
-- Adds a new round to the magazine.
-- @tparam Ammunition round The round to add.
--
function Magazine:addRound( round )
    assert( round:isInstanceOf( Ammunition ), 'Expected an item of type Ammunition!' )
    self.rounds[#self.rounds + 1] = round
end

---
-- Removes a round from the magazine.
--
function Magazine:removeRound()
    table.remove( self.rounds, 1 )
end

---
-- Serializes the magazine.
--
function Magazine:serialize()
    local t = {}

    t['rounds'] = {}
    for i, round in ipairs( self.rounds ) do
        t['rounds'][i] = round:serialize()
    end

    return t
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

---
-- Gets the magazine's maximum capacity.
-- @treturn number The number of rounds the magazine can hold.
--
function Magazine:getCapacity()
    return self.capacity
end

---
-- Gets the magazine's ammunition type.
-- @treturn string The type of ammunition this magazine can hold.
--
function Magazine:getCaliber()
    return self.caliber
end

---
-- Gets a certain round inside of the magazine.
-- @tparam  number     i The index of the round to get.
-- @treturn Ammunition   The round at the specified position.
--
function Magazine:getRound( i )
    return self.rounds[i]
end

---
-- Gets the current number of rounds.
-- @treturn number The current amount of rounds inside of the mag.
--
function Magazine:getNumberOfRounds()
    return #self.rounds
end

---
-- Checks if the magazine is at full capacity.
-- @treturn boolean True if the magazine is full.
--
function Magazine:isFull()
    return #self.rounds == self.capacity
end

---
-- Checks if the magazine is empty.
-- @treturn boolean True if the magazine is empty.
--
function Magazine:isEmpty()
    return #self.rounds == 0
end

return Magazine
