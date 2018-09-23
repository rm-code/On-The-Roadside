---
-- @module Faction
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local Log = require( 'src.util.Log' )
local Node = require( 'src.util.Node' )
local CharacterFactory = require( 'src.characters.CharacterFactory' )
local Character = require( 'src.characters.Character' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Faction = Class( 'Faction' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Initializes a new Faction instance.
-- @tparam string  type The faction's type.
-- @tparam boolean ai   Determines wether the faction is controlled by ai.
--
function Faction:initialize( type, ai )
    self.type = type
    self.ai = ai
end

---
-- Activates this Faction right before it is selected.
--
function Faction:activate()
    self:iterate( function( character )
        if not character:isDead() then
            Log.debug( 'Tick character ' .. tostring( character ), 'Faction' )
            character:setFinishedTurn( false )
        end
    end)
end

---
-- Adds a new Character to this Faction.
-- @tparam Character character The character to add.
--
function Faction:addCharacter( character )
    local node = Node( character )

    -- Initialise root node.
    if not self.root then
        self.root = node
        self.active = self.root
        self.last = self.active
        return
    end

    -- Doubly link the new node.
    self.active:linkNext( node )
    node:linkPrev( self.active )

    -- Make the new node active and mark it as the last node in our list.
    self.active = node
    self.last = self.active
end

---
-- Adds characters to this faction.
-- @tparam number amount The amount of characters to add.
--
function Faction:addCharacters( amount )
    for _ = 1, amount do
        -- Create the new character.
        local character = CharacterFactory.newCharacter( self.type )
        character:setFaction( self )

        -- Add it to this faction.
        self:addCharacter( character )
    end
end

---
-- Recreates saved charaters for each faction.
-- @tparam table savedFactions A table containing the information to load all characters.
--
function Faction:loadCharacters( characters )
    for _, savedCharacter in ipairs( characters ) do
        local character = CharacterFactory.loadCharacter( savedCharacter )
        character:setFaction( self )
        self:addCharacter( character )
    end
end

---
-- Spawns the characters of this Faction on the given map.
-- @tparam Map map The map to spawn the characters on.
--
function Faction:spawnCharacters( map )
    self:iterate( function( character )
        local sx, sy = character:getPosition()

        local tile

        if sx and sy then
            tile = map:getTileAt( sx, sy )
        else
            tile = map:findSpawnPoint( self.type )
        end

        map:setCharacterAt( tile:getX(), tile:getY(), character )
    end)
end

---
-- Deactivates this Faction right before it is deselected.
--
function Faction:deactivate()
    self:iterate( function( character )
        character:resetCurrentAP()
        character:clearActions()
    end)
end

---
-- Finds a certain Character in this Faction and makes him active.
-- @tparam Character character The character to select.
--
function Faction:selectCharacter( character )
    assert( character:isInstanceOf( Character ), 'Expected object of type Character!' )
    local node = self.root
    while node do
        if node:getObject() == character and not node:getObject():isDead() then
            -- Deactivate old character.
            self.active:getObject():deactivate()

            -- Activate new character.
            self.active = node
            self.active:getObject():activate()

            break
        end
        node = node:getNext()
    end
end

---
-- Checks if any of this faction's characters are still alive.
-- @treturn boolean True if at least one character is alive.
--
function Faction:hasLivingCharacters()
    local node = self.root
    while node do
        if not node:getObject():isDead() then
            return true
        end

        if node == self.last then
            break
        end

        node = node:getNext()
    end
    return false
end

---
-- Checks if any of this faction's characters have taken their actions.
-- @treturn boolean True if all characters have finished their turn.
--
function Faction:hasFinishedTurn()
    local node = self.root
    while node do
        if not node:getObject():hasFinishedTurn() then
            return false
        end

        if node == self.last then
            break
        end

        node = node:getNext()
    end
    return true
end

---
-- Gets the next character who hasn't finished his turn yet.
-- @treturn Character The character with unfinished turn.
--
function Faction:nextCharacterForTurn()
    local node = self.root
    while node do
        if not node:getObject():hasFinishedTurn() then
            return node:getObject()
        end

        if node == self.last then
            break
        end

        node = node:getNext()
    end
    error( 'Could not find character with unfinished turn. Use self:hasFinishedTurn() to make sure the faction has characters with unfinshed turns.' )
end

---
-- Iterates over all nodes in this Faction, gets their Characters and passes
-- them to the callback function if they are alive.
-- @tparam function callback The callback to use on the characters.
--
function Faction:iterate( callback )
    local node = self.root
    while node do
        if not node:getObject():isDead() then
            callback( node:getObject() )
        end
        node = node:getNext()
    end
end

---
-- Selects and returns the next Character.
-- @treturn Character The active Character.
--
function Faction:nextCharacter()
    local previousCharacter = self.active:getObject()
    while self.active do
        self.active = self.active:getNext() or self.root
        local character = self.active:getObject()
        if not character:isDead() then
            previousCharacter:deactivate()
            character:activate()
            return character
        end
    end
end

---
-- Selects and returns the previous Character.
-- @treturn Character The active Character.
--
function Faction:prevCharacter()
    -- Get the currently active character.
    local currentCharacter = self.active:getObject()
    while self.active do
        -- Select the previous character or wrap around to the last character
        -- in the list.
        self.active = self.active:getPrev() or self.last

        local previousCharacter = self.active:getObject()
        if not previousCharacter:isDead() then
            currentCharacter:deactivate()
            previousCharacter:activate()
            return previousCharacter
        end
    end
end

---
-- Generates the FOV for characters which can see a certain tile.
-- @tparam Tile tile The tile to check for.
--
function Faction:regenerateFOVSelectively( tile )
    local node = self.root
    while node do
        local character = node:getObject()
        if not character:isDead() and character:canSee( tile ) then
            character:generateFOV()
        end
        node = node:getNext()
    end
end

---
-- Serializes the faction.
-- @treturn table The serialized faction object.
--
function Faction:serialize()
    local t = {}
    local node = self.root
    while node do
        t[#t+1] = node:getObject():serialize()
        node = node:getNext()
    end
    return t
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

---
-- Returns this faction's first (root) character.
-- @treturn Character The first character in the list.
--
function Faction:getFirstCharacter()
    return self.root:getObject()
end

---
-- Returns this faction's currently active character.
-- @treturn Character The active character.
--
function Faction:getCurrentCharacter()
    return self.active:getObject()
end

---
-- Returns the faction's type.
-- @treturn string The faction's id as defined in the faction constants.
--
function Faction:getType()
    return self.type
end

---
-- Wether this faction is controlled by the game's AI.
-- @treturn boolean True if it is controlled by the AI.
--
function Faction:isAIControlled()
    return self.ai
end

return Faction
