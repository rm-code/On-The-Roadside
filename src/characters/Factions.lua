---
-- @module Factions
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local Node = require( 'src.util.Node' )
local Log = require( 'src.util.Log' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Factions = Class( 'Factions' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FACTIONS = require( 'src.constants.FACTIONS' )

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Adds a new faction node to the linked list.
-- @tparam Faction faction The faction to add.
--
function Factions:addFaction( faction )
    local node = Node( faction )

    -- Initialise root node.
    if not self.root then
        self.root = node
        self.active = self.root
        return self.active:getObject()
    end

    -- Doubly link the new node.
    self.active:linkNext( node )
    node:linkPrev( self.active )

    -- Make it the active node.
    self.active = node
    return self.active:getObject()
end

---
-- Find the faction object belonging to the specified identifier.
-- @tparam  string  type The identifier to look for.
-- @treturn Faction      The faction.
--
function Factions:findFaction( type )
    local node = self.root
    while node do
        if node:getObject():getType() == type then
            return node:getObject()
        end
        node = node:getNext()
    end
end

---
-- Selects the next faction and returns the first valid character.
-- @treturn Character The selected Character.
--
function Factions:nextFaction()
    self.active:getObject():deactivate()

    while self.active do
        self.active = self.active:getNext() or self.root
        local faction = self.active:getObject()
        faction:activate()

        if faction:hasLivingCharacters() then
            local current = faction:getCurrentCharacter()
            if current:isDead() then
                return self:getFaction():nextCharacter()
            end
            return current
        end

        Log.debug( string.format( 'All %s characters are dead.', faction:getType() ), 'Factions' )
    end
end

---
-- Iterates over all factions and passes them to the callback function.
-- @tparam function callback The callback to use on the factions.
--
function Factions:iterate( callback )
    local node = self.root
    while node do
        callback( node:getObject() )
        node = node:getNext()
    end
end

---
-- Serializes the Factions object.
-- @treturn table The serialized Factions object.
--
function Factions:serialize()
    local t = {}
    self:iterate( function( faction )
        t[faction:getType()] = faction:serialize()
    end)
    return t
end

---
-- Receives events.
-- @tparam string  event The received event.
-- @tparam varargs ...   Variable arguments.
--
function Factions:receive( event, ... )
    if event == 'TILE_UPDATED' then
        self.active:getObject():regenerateFOVSelectively( ... )
    end
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

---
-- Returns the currently active faction.
-- @treturn Faction The selected Faction.
--
function Factions:getFaction()
    return self.active:getObject()
end

---
-- Returns the player's faction.
-- @treturn Faction The player's Faction.
--
function Factions:getPlayerFaction()
    return self:findFaction( FACTIONS.ALLIED )
end

return Factions
