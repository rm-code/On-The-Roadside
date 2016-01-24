local Object = require( 'src.Object' );
local BaseTile = require( 'src.map.tiles.BaseTile' );

local DIRECTION = require( 'src.enums.Direction' );

local Map = {};

function Map.new()
    local self = Object.new():addInstance( 'Map' );

    local tiles;

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    local function createTiles( grid )
        local newTiles = {};
        for x = 1, #grid do
            for y = 1, #grid[x] do
                newTiles[x] = newTiles[x] or {};
                if grid[x][y] == '.' then
                    newTiles[x][y] = BaseTile.new( 'floor', x, y );
                elseif grid[x][y] == '#' then
                    newTiles[x][y] = BaseTile.new( 'wall', x, y );
                end
            end
        end
        return newTiles;
    end

    ---
    -- Gives each tile a reference to its neighbours.
    --
    local function addNeighbours()
        for x = 1, #tiles do
            for y = 1, #tiles[x] do
                local neighbours = {};

                neighbours[DIRECTION.NORTH]      = self:getTileAt( x    , y - 1 );
                neighbours[DIRECTION.SOUTH]      = self:getTileAt( x    , y + 1 );
                neighbours[DIRECTION.NORTH_EAST] = self:getTileAt( x + 1, y - 1 );
                neighbours[DIRECTION.NORTH_WEST] = self:getTileAt( x - 1, y - 1 );
                neighbours[DIRECTION.SOUTH_EAST] = self:getTileAt( x + 1, y + 1 );
                neighbours[DIRECTION.SOUTH_WEST] = self:getTileAt( x - 1, y + 1 );
                neighbours[DIRECTION.EAST]       = self:getTileAt( x + 1, y     );
                neighbours[DIRECTION.WEST]       = self:getTileAt( x - 1, y     );

                tiles[x][y]:setNeighbours( neighbours );
            end
        end
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:init()
        -- TODO Replace
        local grid = require( 'res.data.maps.example' );
        tiles = createTiles( grid );
        addNeighbours();
    end

    function self:iterate( callback )
        for x = 1, #tiles do
            for y = 1, #tiles[x] do
                callback( tiles[x][y], x, y );
            end
        end
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    function self:getTileAt( x, y )
        return tiles[x] and tiles[x][y];
    end

    return self;
end

return Map;
