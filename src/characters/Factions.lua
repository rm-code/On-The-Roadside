local Object = require( 'src.Object' );
local Faction = require( 'src.characters.Faction' );
local Node = require( 'src.util.Node' );
local Messenger = require( 'src.Messenger' );
local CharacterFactory = require( 'src.characters.CharacterFactory' );
local Log = require( 'src.util.Log' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Factions = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FACTIONS = require( 'src.constants.FACTIONS' );

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Factions.new( map )
    local self = Object.new():addInstance( 'Factions' );

    -- ------------------------------------------------
    -- Private Variables
    -- ------------------------------------------------

    local root;
    local active;
    local player;

    -- ------------------------------------------------
    -- Private Methods
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
            return active:getObject();
        end

        -- Doubly link the new node.
        active:linkNext( node );
        node:linkPrev( active );

        -- Make it the active node.
        active = node;
        return active:getObject();
    end

    ---
    -- Spawns characters on the map.
    -- @param amount  (number) The amount of characters to spawn.
    -- @param faction (string) The faction identifier.
    --
    local function spawnCharacters( amount, faction )
        for _ = 1, amount do
            local spawn = map:findSpawnPoint( faction );
            -- TODO Character spawn based on templates.
            local type = 'human';
            if faction == FACTIONS.NEUTRAL then
                type = 'dog';
            end
            self:addCharacter( CharacterFactory.newCharacter( map, spawn, self:findFaction( faction ), type ));
        end
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    ---
    -- Adds a new character.
    -- @param character (Character) The character to add.
    --
    function self:addCharacter( character )
        local node = root;
        while node do
            if node:getObject():getType() == character:getFaction():getType() then
                node:getObject():addCharacter( character );
                break;
            end
            node = node:getNext();
        end
    end

    ---
    -- Find the faction object belonging to the specified identifier.
    -- @param type (string)  The identifier to look for.
    -- @return     (Faction) The faction.
    --
    function self:findFaction( type )
        local node = root;
        while node do
            if node:getObject():getType() == type then
                return node:getObject();
            end
            node = node:getNext();
        end
    end

    ---
    -- Initialises the Factions object by creating a linked list of factions and
    -- spawning the characters for each faction at random locations on the map.
    --
    function self:init()
        addFaction( Faction.new( FACTIONS.ENEMY,   true  ));
        addFaction( Faction.new( FACTIONS.NEUTRAL, true  ));
        player = addFaction( Faction.new( FACTIONS.ALLIED,  false ));
    end

    ---
    -- Spawns characters on the map.
    --
    function self:spawnCharacters()
        spawnCharacters( 10, FACTIONS.ALLIED  );
        spawnCharacters(  5, FACTIONS.NEUTRAL );
        spawnCharacters( 10, FACTIONS.ENEMY   );
    end

    ---
    -- Selects the next faction and returns the first valid character.
    -- @return (Character) The selected Character.
    --
    function self:nextFaction()
        active:getObject():deactivate();

        map:updateExplorationInfo( active:getObject():getType() );

        while active do
            active = active:getNext() or root;
            local faction = active:getObject();
            faction:activate();

            if faction:hasLivingCharacters() then
                map:updateExplorationInfo( faction:getType() );

                local current = faction:getCurrentCharacter();
                if current:isDead() then
                    return self:getFaction():nextCharacter();
                end
                Messenger.publish( 'SWITCH_CHARACTERS', current );
                return current;
            end

            Log.debug( string.format( 'All %s characters are dead.', faction:getType() ), 'Factions' );
        end
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    ---
    -- Returns the currently active faction.
    -- @return (Faction) The selected Faction.
    --
    function self:getFaction()
        return active:getObject();
    end

    function self:getPlayerFaction()
        return player;
    end

    return self;
end

return Factions;
