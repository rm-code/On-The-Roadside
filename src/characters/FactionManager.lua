local Faction = require( 'src.characters.Faction' );
local Node = require( 'src.characters.Node' );

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FACTIONS = require( 'src.constants.Factions' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local FactionManager = {};

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local root;
local active;

-- ------------------------------------------------
-- Local Functions
-- ------------------------------------------------

---
-- Adds a new faction node to the linked list.
-- @param faction (number) An index to identify the faction.
--
local function addFaction( faction )
    local node = Node.new( faction );

    -- Initialise root node.
    if not root then
        root = node;
        active = root;
        return;
    end

    -- Doubly link the new node.
    active:linkNext( node );
    node:linkPrev( active );

    -- Make it the active node.
    active = node;
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Resets the characters of the active faction.
--
function FactionManager.clearCharacters()
    active:getObject():iterate( function( character )
        character:resetActionPoints();
        character:clearActions();
        character:removePath();
        character:removeLineOfSight();
    end);
end

---
-- Initialises the FactionManager by creating a linked list of factions.
--
function FactionManager.init()
    addFaction( Faction.new( FACTIONS.ENEMY ));
    addFaction( Faction.new( FACTIONS.NEUTRAL ));
    addFaction( Faction.new( FACTIONS.ALLIED ));
end

---
-- Adds a new character.
-- @param tile    (Tile)   The tile to place the character on.
-- @param faction (number) The index of the faction to add the character to.
--
function FactionManager.newCharacter( tile, faction )
    local node = root;
    while node do
        if node:getObject():getType() == faction then
            node:getObject():addCharacter( tile, faction );
            break;
        end
        node = node:getNext();
    end
end

---
-- Selects the next character of the active faction and returns it.
-- @return (Character) The selected Character.
--
function FactionManager.nextCharacter()
    return active:getObject():nextCharacter();
end

---
-- Selects the next faction and returns the first valid character.
-- @return (Character) The selected Character.
--
function FactionManager.nextFaction()
    while active do
        active = active:getNext() or root;
        if active:getObject():hasLivingCharacters() then
            if active:getObject():getCurrentCharacter():isDead() then
                return FactionManager.nextCharacter();
            end
            return active:getObject():getCurrentCharacter();
        end
    end
end

---
-- Selects the previous character of the active faction and returns it.
-- @return (Character) The selected Character.
--
function FactionManager.prevCharacter()
    return active:getObject():prevCharacter();
end

---
-- Searches a faction for the character located on the given tile and selects him.
-- @param tile (Tile)      The tile on which the character is located.
-- @return     (Character) The selected Character.
--
function FactionManager.selectCharacter( tile )
    if tile:isOccupied() then
        active:getObject():findCharacter( tile:getCharacter() );
    end
    return FactionManager.getCurrentCharacter();
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

---
-- Returns the currently active character.
-- @return (Character) The selected Character.
--
function FactionManager.getCurrentCharacter()
    return active:getObject():getCurrentCharacter();
end

---
-- Returns the currently active faction.
-- @return (Faction) The selected Faction.
--
function FactionManager.getFaction()
    return active:getObject();
end

return FactionManager;
