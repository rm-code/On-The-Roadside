local Object = require('src.Object');
local Node = require('src.characters.Node');
local Character = require( 'src.characters.Character' );
local ItemFactory = require('src.items.ItemFactory');

local Faction = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FACTIONS = require( 'src.constants.Factions' );
local CLOTHING_SLOTS = require('src.constants.ClothingSlots');

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Faction.new( type )
    local self = Object.new():addInstance( 'Faction' );

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

    ---
    -- Creates the equipment for a character.
    -- @param character (Character) The character to equip with new items.
    --
    local function createEquipment( character )
        local weapon = ItemFactory.createWeapon();
        local magazine = ItemFactory.createMagazine( weapon:getAmmoType(), 30 );
        weapon:reload( magazine );

        character:getEquipment():addItem( weapon );
        character:getEquipment():addItem( ItemFactory.createBag() );
        character:getEquipment():addItem( ItemFactory.createClothing( CLOTHING_SLOTS.HEADGEAR ));
        character:getEquipment():addItem( ItemFactory.createClothing( CLOTHING_SLOTS.GLOVES   ));
        character:getEquipment():addItem( ItemFactory.createClothing( CLOTHING_SLOTS.SHIRT    ));
        character:getEquipment():addItem( ItemFactory.createClothing( CLOTHING_SLOTS.JACKET   ));
        character:getEquipment():addItem( ItemFactory.createClothing( CLOTHING_SLOTS.TROUSERS ));
        character:getEquipment():addItem( ItemFactory.createClothing( CLOTHING_SLOTS.FOOTWEAR ));
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:activate()
        updateExplorationInfo();
    end

    function self:deactivate()
        self:iterate( function( character )
            character:resetActionPoints();
            character:clearActions();
            character:removePath();
            character:removeLineOfSight();
        end);
        updateExplorationInfo();
    end

    function self:addCharacter( map, tile )
        -- Create character and calculate initial FOV.
        local character = Character.new( map, tile, self );
        createEquipment( character );
        character:generateFOV();

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

    function self:findCharacter( character )
        assert( character:instanceOf( 'Character' ), 'Expected object of type Character!' );
        local node = root;
        while node do
            if node:getObject() == character and not node:getObject():isDead() then
                character:generateFOV();
                local previous = active;
                active = node;
                previous:getObject():generateFOV();
                break;
            end
            node = node:getNext();
        end
    end

    function self:iterate( callback )
        local node = root;
        while node do
            callback( node:getObject() );
            node = node:getNext();
        end
    end

    function self:getCurrentCharacter()
        return active:getObject();
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

    function self:nextCharacter()
        local previousCharacter = active:getObject();
        while active do
            active = active:getNext() or root;
            local character = active:getObject();
            if not character:isDead() then
                previousCharacter:generateFOV();
                character:generateFOV();
                return character;
            end
        end
    end

    function self:prevCharacter()
        local previousCharacter = active:getObject();
        while active do
            active = active:getPrev() or last;
            local character = active:getObject();
            if not character:isDead() then
                previousCharacter:generateFOV();
                character:generateFOV();
                return character;
            end
        end
    end

    function self:hasLivingCharacters()
        local node = root;
        while node do
            if not node:getObject():isDead() then
                return true;
            end
            node = node:getNext();
        end
        return false;
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

    function self:getType()
        return type;
    end

    function self:isAIControlled()
        return type == FACTIONS.NEUTRAL or type == FACTIONS.ENEMY;
    end

    return self;
end

return Faction;
