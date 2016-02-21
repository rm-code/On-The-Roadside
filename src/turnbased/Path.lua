local Object = require('src.Object');

local Path = {};

function Path.new( path )
    local self = Object.new():addInstance( 'Path' );

    local length = #path;
    for i = 1, #path do
        path[i]:setDirty( true );
    end

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
            callback( path[i] );
        end
    end

    function self:getNextNode()
        return table.remove( path );
    end

    function self:getLength()
        return length;
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

    function self:getTarget()
        return path[1];
    end

    return self;
end

return Path;
