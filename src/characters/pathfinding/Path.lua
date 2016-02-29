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

    -- Initialise the tiles along the path as dirty.
    local length = #path;
    for i = 1, #path do
        path[i]:setDirty( true );
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
    -- Sets the tiles the path leads through to dirty to make sure the path
    -- is drawn correctly.
    --
    function self:refresh()
        for i = 1, #path do
            path[i]:setDirty( true );
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
        return length;
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
