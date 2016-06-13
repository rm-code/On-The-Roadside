local Object = require( 'src.Object' );

local TileFactory = require( 'src.map.tiles.TileFactory' );
local WorldObjectFactory = require( 'src.map.worldobjects.WorldObjectFactory' );

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local DIRECTION = require( 'src.constants.Direction' );

local INFO_FILE = love.filesystem.load( 'res/data/maps/info.lua' )();
local GROUND_LAYER = love.image.newImageData( 'res/data/maps/Map_Ground.png' );
local OBJECT_LAYER = love.image.newImageData( 'res/data/maps/Map_Objects.png' );

local Map = {};

function Map.new()
    local self = Object.new():addInstance( 'Map' );

    local tiles;

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    local function createTile( x, y, r, g, b, _ )
        local tile;
        for _, info in ipairs( INFO_FILE.ground ) do
            if info.r == r and info.g == g and info.b == b then
                tile = info.tile;
                break;
            end
        end
        return TileFactory.create( x, y, tile );
    end

    local function createWorldObject( tile, r, g, b, a )
        if a == 0 then
            return;
        end

        local object;
        for _, info in ipairs( INFO_FILE.objects ) do
            if info.r == r and info.g == g and info.b == b then
                object = info.object;
                break;
            end
        end
        tile:addWorldObject( WorldObjectFactory.create( object ));
    end

    local function createTiles()
        local newTiles = {};

        for x = 1, GROUND_LAYER:getWidth() do
            for y = 1, GROUND_LAYER:getHeight() do
                newTiles[x] = newTiles[x] or {};
                newTiles[x][y] = createTile( x, y, GROUND_LAYER:getPixel( x - 1, y - 1 ));
            end
        end

        return newTiles;
    end

    local function createWorldObjects()
        for x = 1, OBJECT_LAYER:getWidth() do
            for y = 1, OBJECT_LAYER:getHeight() do
                createWorldObject( tiles[x][y], OBJECT_LAYER:getPixel( x - 1, y - 1 ));
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
        tiles = createTiles();
        createWorldObjects();
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
                local target = self:getTileAt( math.floor( ox ), math.floor( oy ));
                if not target then
                    break;
                end
                target:setVisible( true );
                target:setExplored( true );
                target:setDirty( true ); -- Mark tile for updating.

                if target:hasWorldObject() and target:getWorldObject():blocksVision() then
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
