local Object = require('src.Object');
local Node = require('src.characters.Node');
local CharacterFactory = require( 'src.characters.CharacterFactory' );
local Messenger = require( 'src.Messenger' );

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
    local mapInfo = {};

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    ---
    -- Marks all explored tiles for drawing updates.
    --
    local function updateExplorationInfo()
        for _, rx in pairs( mapInfo ) do
            for _, target in pairs( rx ) do
                target:setDirty( true );
            end
        end
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    ---
    -- Activates this Faction right before it is selected.
    --
    function self:activate()
        updateExplorationInfo();
    end

    ---
    -- Adds a new Character to this Faction.
    -- @param map  (Map)  The game's map.
    -- @param tile (Tile) The tile on which to spawn this character.
    --
    function self:addCharacter( map, tile )
        -- Create character and calculate initial FOV.
        local character = CharacterFactory.newCharacter( map, tile, self );
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
    -- Adds a tile to the list of explored tiles for this faction.
    -- @param tx     (number) The target-tile's position along the x-axis.
    -- @param ty     (number) The target-tile's position along the y-axis.
    -- @param target (Tile)   The target-tile.
    --
    function self:addExploredTile( tx, ty, target )
        mapInfo[tx] = mapInfo[tx] or {};
        mapInfo[tx][ty] = target;
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
            character:removePath();
            character:removeLineOfSight();
        end);
        updateExplorationInfo();
    end

    ---
    -- Finds a certain Character in this Faction and makes him active.
    -- @param character (Character) The character to select.
    --
    function self:selectCharacter( character )
        assert( character:instanceOf( 'Character' ), 'Expected object of type Character!' );
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
    -- Checks if the target tile has been explored by this Faction.
    -- @param target (Tile)    The tile to check.
    -- @return       (boolean) Wether this tile has been explored.
    --
    function self:hasExplored( target )
        local tx, ty = target:getPosition();
        if not mapInfo[tx] then
            return false;
        end
        return mapInfo[tx][ty] ~= nil;
    end

    ---
    -- Iterates over all nodes in this Faction, gets their Characters and passes
    -- them to the callback function.
    -- @param callback (function) The callback to use on the characters.
    --
    function self:iterate( callback )
        local node = root;
        while node do
            callback( node:getObject() );
            node = node:getNext();
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
    -- @return (number) The faction's number as defined in the faction constants.
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
