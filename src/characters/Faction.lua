local Object = require('src.Object');
local Node = require('src.characters.Node');
local Character = require( 'src.characters.Character' );

local Faction = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FACTIONS = require( 'src.constants.Factions' );

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
    -- Adds a tile to the list of explored tiles for this faction.
    -- @param tx     (number) The target-tile's position along the x-axis.
    -- @param ty     (number) The target-tile's position along the y-axis.
    -- @param target (Tile)   The target-tile.
    --
    local function addExploredTile( tx, ty, target )
        mapInfo[tx] = mapInfo[tx] or {};
        mapInfo[tx][ty] = target;
    end

    ---
    -- Casts rays in a circle around the character to determine all tiles he can
    -- see. Rays stop if they reach the map border or a world object which has
    -- the blocksVision attribute set to true.
    -- TODO Replace FOV algorithm with something more elaborate / efficient.
    -- @param character (Character) The character to create the FOV for.
    -- @param map       (Map)       The map on which to cast the rays.
    --
    local function castViewRays( character, map )
        local range = character:getViewRange();
        local tile = character:getTile();

        -- Calculate the new FOV information.
        for i = 1, 360 do
            local ox, oy = tile:getX() + 0.5, tile:getY() + 0.5;
            local rad    = math.rad( i );
            local rx, ry = math.cos( rad ), math.sin( rad );

            for _ = 1, range do
                local target = map:getTileAt( math.floor( ox ), math.floor( oy ));
                if not target then
                    break;
                end
                local tx, ty = target:getPosition();

                -- Add tile to this character's FOV.
                character:addSeenTile( tx, ty, target );

                -- Add tile to list of explored tiles.
                addExploredTile( tx, ty, target );

                -- Mark tile for drawing update.
                target:setDirty( true );

                if target:hasWorldObject() and target:getWorldObject():blocksVision() then
                    break;
                end

                ox = ox + rx;
                oy = oy + ry;
            end
        end
    end

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

    function self:addCharacter( tile, faction )
        local node = Node.new( Character.new( tile, faction ));

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

    function self:findCharacter( character )
        assert( character:instanceOf( 'Character' ), 'Expected object of type Character!' );
        local node = root;
        while node do
            if node:getObject() == character and not node:getObject():isDead() then
                active = node;
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
    -- Generates the FOV for all characters in this faction.
    -- @param map (Map) The map object to calculate the visibility on.
    --
    function self:generateFOV( map )
        local node = root;
        while node do
            local character = node:getObject();
            character:resetFOV();
            if not character:isDead() then
                castViewRays( character, map );
            end
            node = node:getNext();
        end
    end

    function self:nextCharacter()
        while active do
            active = active:getNext() or root;
            if not active:getObject():isDead() then
                return active:getObject();
            end
        end
    end

    function self:prevCharacter()
        while active do
            active = active:getPrev() or last;
            if not active:getObject():isDead() then
                return active:getObject();
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
