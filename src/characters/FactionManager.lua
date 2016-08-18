local Faction = require( 'src.characters.Faction' );
local Node = require( 'src.characters.Node' );
local Messenger = require( 'src.Messenger' );

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

---
-- Adds a new character.
-- @param map     (Map)    A reference to the map object.
-- @param tile    (Tile)   The tile to place the character on.
-- @param faction (string) The faction identifier to add the character to.
--
local function addCharacter( map, tile, faction )
    local node = root;
    while node do
        if node:getObject():getType() == faction then
            node:getObject():addCharacter( map, tile );
            break;
        end
        node = node:getNext();
    end
end

---
-- Spawns characters on the map.
-- @param map     (Map)    A reference to the map object.
-- @param amount  (number) The amount of characters to spawn.
-- @param faction (string) The faction identifier.
--
local function spawnCharacters( map, amount, faction )
    for _ = 1, amount do
        addCharacter( map, map:findSpawnPoint( faction ), faction );
    end
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Initialises the FactionManager by creating a linked list of factions and
-- spawning the characters for each faction at random locations on the map.
-- @param map (Map) A reference to the map object.
--
function FactionManager.init( map )
    addFaction( Faction.new( FACTIONS.ENEMY,   true  ));
    addFaction( Faction.new( FACTIONS.NEUTRAL, true  ));
    addFaction( Faction.new( FACTIONS.ALLIED,  false ));

    spawnCharacters( map, 10, FACTIONS.ALLIED  );
    spawnCharacters( map,  5, FACTIONS.NEUTRAL );
    spawnCharacters( map, 10, FACTIONS.ENEMY   );
end

---
-- Selects the next faction and returns the first valid character.
-- @return (Character) The selected Character.
--
function FactionManager.nextFaction()
    active:getObject():deactivate();
    while active do
        active = active:getNext() or root;
        if active:getObject():hasLivingCharacters() then
            active:getObject():activate();
            local current = active:getObject():getCurrentCharacter();
            if current:isDead() then
                return FactionManager.getFaction():nextCharacter();
            end
            Messenger.publish( 'SWITCH_CHARACTERS', current );
            return current;
        end
    end
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

---
-- Returns the currently active faction.
-- @return (Faction) The selected Faction.
--
function FactionManager.getFaction()
    return active:getObject();
end

return FactionManager;
