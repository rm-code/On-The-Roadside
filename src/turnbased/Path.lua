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

    return self;
end

return Path;
