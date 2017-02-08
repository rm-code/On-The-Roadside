local Object = require('src.Object');
local Walk = require( 'src.characters.actions.Walk' );
local Open = require( 'src.characters.actions.Open' );
local ClimbOver = require( 'src.characters.actions.ClimbOver' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Path = {};

---
-- Creates a new path object.
--
function Path.new()
    local self = Object.new():addInstance( 'Path' );

    local path = {};
    local cost = 0;

    -- ------------------------------------------------
    -- Local Functions
    -- ------------------------------------------------

    ---
    -- Generate smart actions for openable objects. These are a special case,
    -- because usually the player will want to move a character onto the tile
    -- after the object is openend.
    -- @param worldObject (WorldObject) The worldobject to interact with.
    -- @param character   (Character)   The character that interacts with the object.
    -- @param tile        (Tile)        The tile containing the worldobject.
    -- @param index       (number)      The tile's position in the path.
    --
    local function handleOpenableObjects( worldObject, character, tile, index )
        if not worldObject:isPassable() then
            character:enqueueAction( Open.new( character, tile ));
            -- Don't create a walk action if the tile is the last one in the path.
            if index ~= 1 then
                character:enqueueAction( Walk.new( character, tile ));
            end
            return;
        end
        character:enqueueAction( Walk.new( character, tile ));
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    ---
    -- Checks if the path contains a certain tile.
    -- @param tile (Tile)   The tile to check for.
    -- @return     (number) The index of the tile in the path.
    --
    function self:contains( tile )
        for i = 1, #path do
            if tile == path[i] then
                return i;
            end
        end
    end

    ---
    -- Iterates over the path. The target tile will be processed at last.
    -- @param callback (function) A function to call on every tile.
    --
    function self:iterate( callback )
        for i = #path, 1, -1 do
            callback( path[i], i );
        end
    end

    ---
    -- Adds a new tile to this path.
    -- @param tile  (Tile)   A tile to add to this path.
    -- @param dcost (number) The cost to traverse this tile.
    --
    function self:addNode( tile, dcost )
        path[#path + 1] = tile;
        cost = cost + dcost;
    end

    ---
    -- Automagically generates appropriate Actions for each tile in the path.
    -- For example if the character moves through a tile with a door object this
    -- function will generate an action to open the door and an action to walk
    -- onto the tile itself.
    -- @param character (Character) The character to create the actions for.
    --
    function self:generateActions( character )
        for index = #path, 1, -1 do
            local tile = path[index];
            if tile:hasWorldObject() then
                local worldObject = tile:getWorldObject();

                if worldObject:isOpenable() then
                    handleOpenableObjects( worldObject, character, tile, index );
                end

                if worldObject:isClimbable() then
                    character:enqueueAction( ClimbOver.new( character, tile ));
                end
            else
                character:enqueueAction( Walk.new( character, tile ));
            end
        end
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    ---
    -- Returns the length of the path.
    -- @return (number) The length of the path.
    --
    function self:getLength()
        return #path;
    end

    ---
    -- Returns the target tile of the path.
    -- @return (Tile) The target of the path.
    --
    function self:getTarget()
        return path[1];
    end

    function self:getCost()
        return cost;
    end

    return self;
end

return Path;
