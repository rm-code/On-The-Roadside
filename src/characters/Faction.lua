local Log = require( 'src.util.Log' );
local Object = require('src.Object');
local Node = require('src.util.Node');
local Messenger = require( 'src.Messenger' );
local CharacterFactory = require( 'src.characters.CharacterFactory' )
local Character = require( 'src.characters.Character' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Faction = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Faction.new( type, controlledByAi )
    local self = Object.new():addInstance( 'Faction' );

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local root;
    local active;
    local last;

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    ---
    -- Activates this Faction right before it is selected.
    --
    function self:activate()
        self:iterate( function( character )
            if not character:isDead() then
                Log.debug( 'Tick character ' .. tostring( character ), 'Faction' );
                character:setFinishedTurn( false );
                character:tickOneTurn();
            end
        end);
    end

    ---
    -- Adds a new Character to this Faction.
    -- @param character (Character) The character to add.
    --
    function self:addCharacter( character )
        local node = Node.new( character );

        -- Initialise root node.
        if not root then
            root = node;
            active = root;
            last = active;
            return;
        end

        -- Doubly link the new node.
        active:linkNext( node );
        node:linkPrev( active );

        -- Make the new node active and mark it as the last node in our list.
        active = node;
        last = active;
    end

    ---
    -- Adds characters to this faction.
    -- @tparam number amount The amount of characters to add.
    -- @tparam string ctype  The type of characters to add.
    --
    function self:addCharacters( amount, ctype )
        for _ = 1, amount do
            -- Create the new character.
            local character = CharacterFactory.newCharacter( ctype, self:getType() )
            character:setFaction( self )

            -- Add it to this faction.
            self:addCharacter( character )
        end
    end

    ---
    -- Recreates saved charaters for each faction.
    -- @tparam table savedFactions A table containing the information to load all characters.
    --
    function self:loadCharacters( characters )
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
    function self:spawnCharacters( map )
        self:iterate( function( character )
            local sx, sy = character:getSavedPosition()
            character:setSavedPosition( nil, nil )

            local tile

            if sx and sy then
                tile = map:getTileAt( sx, sy )
            else
                tile = map:findSpawnPoint( type )
            end

            tile:setCharacter( character )
            character:setTile( tile )
            character:setMap( map )
        end)
    end

    ---
    -- Checks if any of the characters in this Faction can see the target tile.
    -- @param target (Tile)    The tile to check visibility for.
    -- @return       (boolean) Wether a character can see this tile.
    --
    function self:canSee( tile )
        local node = root;
        while node do
            if node:getObject():canSee( tile ) then
                return true;
            end
            node = node:getNext();
        end
    end

    ---
    -- Deactivates this Faction right before it is deselected.
    --
    function self:deactivate()
        self:iterate( function( character )
            character:resetActionPoints();
            character:clearActions();
        end);
    end

    ---
    -- Finds a certain Character in this Faction and makes him active.
    -- @param character (Character) The character to select.
    --
    function self:selectCharacter( character )
        assert( character:isInstanceOf( Character ), 'Expected object of type Character!' )
        local node = root;
        while node do
            if node:getObject() == character and not node:getObject():isDead() then
                -- Deactivate old character.
                active:getObject():deactivate();

                -- Activate new character.
                active = node;
                active:getObject():activate();

                Messenger.publish( 'SWITCH_CHARACTERS', active:getObject() );
                break;
            end
            node = node:getNext();
        end
    end

    ---
    -- Checks if any of this faction's characters are still alive.
    -- @return (boolean) True if at least one character is alive.
    --
    function self:hasLivingCharacters()
        local node = root;
        while node do
            if not node:getObject():isDead() then
                return true;
            end

            if node == last then
                break;
            end

            node = node:getNext();
        end
        return false;
    end

    ---
    -- Checks if any of this faction's characters have taken their actions.
    -- @return (boolean) True if all characters have finished their turn.
    --
    function self:hasFinishedTurn()
        local node = root;
        while node do
            if not node:getObject():hasFinishedTurn() then
                return false;
            end

            if node == last then
                break;
            end

            node = node:getNext();
        end
        return true;
    end

    ---
    -- Gets the next character who hasn't finished his turn yet.
    -- @return (Character) The character with unfinished turn.
    --
    function self:nextCharacterForTurn()
        local node = root;
        while node do
            if not node:getObject():hasFinishedTurn() then
                return node:getObject();
            end

            if node == last then
                break;
            end

            node = node:getNext();
        end
        error( 'Could not find character with unfinished turn. Use self:hasFinishedTurn() to make sure the faction has characters with unfinshed turns.' )
    end

    ---
    -- Iterates over all nodes in this Faction, gets their Characters and passes
    -- them to the callback function if they are alive.
    -- @tparam function callback The callback to use on the characters.
    --
    function self:iterate( callback )
        local node = root
        while node do
            if not node:getObject():isDead() then
                callback( node:getObject() )
            end
            node = node:getNext()
        end
    end

    ---
    -- Selects and returns the next Character.
    -- @return (Character) The active Character.
    --
    function self:nextCharacter()
        local previousCharacter = active:getObject();
        while active do
            active = active:getNext() or root;
            local character = active:getObject();
            if not character:isDead() then
                previousCharacter:deactivate();
                character:activate();
                Messenger.publish( 'SWITCH_CHARACTERS', character );
                return character;
            end
        end
    end

    ---
    -- Selects and returns the previous Character.
    -- @return (Character) The active Character.
    --
    function self:prevCharacter()
        local previousCharacter = active:getObject();
        while active do
            active = active:getPrev() or last;
            local character = active:getObject();
            if not character:isDead() then
                previousCharacter:activate();
                character:deactivate();
                Messenger.publish( 'SWITCH_CHARACTERS', character );
                return character;
            end
        end
    end

    ---
    -- Generates the FOV for characters which can see a certain tile.
    -- @param tile (Tile) The tile to check for.
    --
    function self:regenerateFOVSelectively( tile )
        local node = root;
        while node do
            local character = node:getObject();
            if not character:isDead() and character:canSee( tile ) then
                character:generateFOV();
            end
            node = node:getNext();
        end
    end

    function self:serialize()
        local t = {};
        local node = root;
        while node do
            t[#t+1] = node:getObject():serialize();
            node = node:getNext();
        end
        return t;
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    ---
    -- Returns this faction's currently active character.
    -- @return (Character) The active character.
    --
    function self:getCurrentCharacter()
        return active:getObject();
    end

    ---
    -- Returns the faction's type.
    -- @return (string) The faction's id as defined in the faction constants.
    --
    function self:getType()
        return type;
    end

    ---
    -- Wether this faction is controlled by the game's AI.
    -- @return (boolean) True if it is controlled by the AI.
    --
    function self:isAIControlled()
        return controlledByAi;
    end

    return self;
end

return Faction;
