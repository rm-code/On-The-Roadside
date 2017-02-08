local Object = require('src.Object');

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
