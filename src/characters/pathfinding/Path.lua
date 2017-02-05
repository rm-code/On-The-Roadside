local Object = require('src.Object');

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Path = {};

---
-- Creates a new path object.
-- @param path (table) A sequence containing a path.
--
function Path.new( path )
    local self = Object.new():addInstance( 'Path' );

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
            local success = callback( path[i], i );
            if not success then
                break;
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

    return self;
end

return Path;
