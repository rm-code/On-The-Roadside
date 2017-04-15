local Object = require( 'src.Object' );
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
local STATUS_EFFECTS = require( 'src.constants.STATUS_EFFECTS' )

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
    -- Adds a new faction node to the linked list.
    -- @tparam Faction faction The faction to add.
    --
    function self:addFaction( faction )
        local node = Node.new( faction )

        -- Initialise root node.
        if not root then
            root = node
            active = root
            return active:getObject()
        end

        -- Doubly link the new node.
        active:linkNext( node )
        node:linkPrev( active )

        -- Make it the active node.
        active = node
        return active:getObject()
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
    -- Spawns characters on the map.
    -- @tparam number amount  The amount of characters to spawn.
    -- @tparam string faction The faction to spawn the characters for.
    --
    function self:spawnCharacters( amount, faction )
        for _ = 1, amount do
            local spawn = map:findSpawnPoint( faction )
            -- TODO Character spawn based on templates.
            local type = 'human'
            if faction == FACTIONS.NEUTRAL then
                type = 'dog'
            end
            self:addCharacter( CharacterFactory.newCharacter( map, spawn, self:findFaction( faction ), type ))
        end
    end

    ---
    -- Recreates saved charaters for each faction.
    -- @tparam table savedFactions A table containing the information to load all characters.
    --
    function self:loadCharacters( savedFactions )
        for type, sfaction in pairs( savedFactions ) do
            local faction = self:findFaction( type )
            for _, savedCharacter in ipairs( sfaction ) do
                if not savedCharacter.body.statusEffects[STATUS_EFFECTS.DEATH] then
                    local tile = map:getTileAt( savedCharacter.x, savedCharacter.y )
                    faction:addCharacter( CharacterFactory.loadCharacter( map, tile, faction, savedCharacter ))
                end
            end
        end
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

    ---
    -- Iterates over all factions and passes them to the callback function.
    -- @tparam function callback The callback to use on the factions.
    --
    function self:iterate( callback )
        local node = root;
        while node do
            callback( node:getObject() )
            node = node:getNext()
        end
    end

    function self:serialize()
        local t = {}
        t[FACTIONS.ALLIED]  = self:findFaction( FACTIONS.ALLIED  ):serialize();
        t[FACTIONS.NEUTRAL] = self:findFaction( FACTIONS.NEUTRAL ):serialize();
        t[FACTIONS.ENEMY]   = self:findFaction( FACTIONS.ENEMY   ):serialize();
        return t;
    end

    function self:receive( event, ... )
        if event == 'TILE_UPDATED' then
            local tile = ...;
            assert( tile:instanceOf( 'Tile' ), 'Expected an object of type Tile.' );
            active:getObject():regenerateFOVSelectively( tile );
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
        return self:findFaction( FACTIONS.ALLIED )
    end

    return self;
end

return Factions;
