local Object = require('src.Object');
local Walk = require( 'src.characters.actions.Walk' );
local Open = require( 'src.characters.actions.Open' );
local OpenInventory = require( 'src.characters.actions.OpenInventory' );
local ClimbOver = require( 'src.characters.actions.ClimbOver' )

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
    -- @param             (boolean)     Return true if the actions have been enqueued.
    --
    local function handleOpenableObjects( worldObject, character, tile, index )
        if not worldObject:isPassable() then
            local success = character:enqueueAction( Open.new( character, tile ));
            -- Don't create a walk action if the tile is the last one in the path.
            if index ~= 1 then
                success = character:enqueueAction( Walk( character, tile ))
            end
            return success;
        end
        return character:enqueueAction( Walk( character, tile ))
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

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
        local generatedAction = false;
        for index = #path, 1, -1 do
            local tile = path[index];
            local success;

            if tile:hasWorldObject() then
                local worldObject = tile:getWorldObject();

                if worldObject:isOpenable() then
                    success = handleOpenableObjects( worldObject, character, tile, index );
                end

                if worldObject:isClimbable() then
                    success = character:enqueueAction( ClimbOver( character, tile ))
                end

                if worldObject:isContainer() then
                    character:enqueueAction( OpenInventory.new( character, tile ));
                end
            else
                success = character:enqueueAction( Walk( character, tile ))
            end

            -- Stop adding actions if the previous one wasn't added correctly.
            if not success then
                break;
            else
                generatedAction = true;
            end
        end
        return generatedAction;
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
