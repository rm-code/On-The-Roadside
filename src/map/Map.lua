local Object = require( 'src.Object' );

local Asphalt = require( 'src.map.tiles.Asphalt' );
local Water   = require( 'src.map.tiles.Water' );

local Wall = require( 'src.map.worldobjects.Wall' );
local Door = require( 'src.map.worldobjects.Door' );

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local DIRECTION = require( 'src.constants.Direction' );
local TILES = {
    ['.'] = function( x, y ) return Asphalt.new( x, y ) end,
    ['~'] = function( x, y ) return Water.new( x, y ) end,
}

local WORLD_OBJECTS = {
    ['#'] = function( x, y ) return  Wall.new( x, y ) end,
    ['+'] = function( x, y ) return  Door.new( x, y ) end
}

local Map = {};

function Map.new()
    local self = Object.new():addInstance( 'Map' );

    local tiles;

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    local function createTile( type, x, y )
        assert( TILES[type], 'Tile of type: ' .. type .. ' does not exist!' );
        return TILES[type]( x, y );
    end

    local function createWorldObject( type, tile )
        assert( WORLD_OBJECTS[type], 'WorldObject of type: ' .. type .. ' does not exist!' );
        tile:addWorldObject( WORLD_OBJECTS[type]() );
    end

    local function createTiles( tilelayer )
        local newTiles = {};
        for x = 1, #tilelayer do
            for y = 1, #tilelayer[x] do
                newTiles[x] = newTiles[x] or {};
                newTiles[x][y] = createTile( tilelayer[x][y], x, y );
            end
        end
        return newTiles;
    end

    local function createWorldObjects( objectlayer )
        for x = 1, #objectlayer do
            for y = 1, #objectlayer[x] do
                if objectlayer[x][y] ~= ' ' then -- Ignore placeholders.
                    createWorldObject( objectlayer[x][y], tiles[x][y] );
                end
            end
        end
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

                tiles[x][y]:addNeighbours( neighbours );
            end
        end
    end

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    function self:init()
        -- TODO Replace
        local layout = require( 'res.data.maps.example' );
        tiles = createTiles( layout.tilelayer );
        createWorldObjects( layout.objectlayer );
        addNeighbours();
    end

    function self:iterate( callback )
        for x = 1, #tiles do
            for y = 1, #tiles[x] do
                callback( tiles[x][y], x, y );
            end
        end
    end

    ---
    -- Resets the visibility flags for all visible tiles in the map.
    --
    function self:resetVisibility()
        self:iterate( function( tile )
            if tile:isVisible() then
                tile:setVisible( false );
                tile:setDirty( true );
            end
        end)
    end

    ---
    -- Cast rays in a 360° radius and marks tiles visible.
    -- @param tile (Tile)    The tile to start at.
    -- @param range (number) The view range to use.
    --
    function self:calculateVisibility( tile, range )
        local tx, ty = tile:getPosition();

        for i = 1, 360 do
            local ox, oy = tx + 0.5, ty + 0.5;
            local rad    = math.rad( i );
            local rx, ry = math.cos( rad ), math.sin( rad );

            for _ = 1, range do
                local target = tiles[math.floor( ox )][math.floor( oy )];
                target:setVisible( true );
                target:setExplored( true );
                target:setDirty( true ); -- Mark tile for updating.
                if not target:isPassable() then
                    break;
                end
                ox = ox + rx;
                oy = oy + ry;
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
