local Object = require( 'src.Object' );

local TileFactory = require( 'src.map.tiles.TileFactory' );
local WorldObjectFactory = require( 'src.map.worldobjects.WorldObjectFactory' );

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local DIRECTION = require( 'src.constants.Direction' );

local Map = {};

function Map.new()
    local self = Object.new():addInstance( 'Map' );

    local tiles;

    -- ------------------------------------------------
    -- Public Functions
    -- ------------------------------------------------

    local function createTile( x, y, r, g, b, _ )
        if r == 105 and g == 105 and b == 105 then
            return TileFactory.create( x, y, 'tile_asphalt' );
        elseif r == 0 and g == 255 and b == 0 then
            return TileFactory.create( x, y, 'tile_grass' );
        elseif r == 0 and g == 0 and b == 255 then
            return TileFactory.create( x, y, 'tile_water' );
        end
        return TileFactory.create( x, y, 'tile_soil' );
    end

    local function createWorldObject( tile, r, g, b, a )
        if a == 0 then
            return
        elseif r == 255 and g == 255 and b == 0 then
            tile:addWorldObject( WorldObjectFactory.create( 'worldobject_door' ));
        else
            tile:addWorldObject( WorldObjectFactory.create( 'worldobject_wall' ));
        end
    end

    local function createTiles()
        local groundLayer = love.image.newImageData( 'res/data/maps/Map_Ground.png' );
        local newTiles = {};

        for x = 1, groundLayer:getWidth() do
            for y = 1, groundLayer:getHeight() do
                newTiles[x] = newTiles[x] or {};
                newTiles[x][y] = createTile( x, y, groundLayer:getPixel( x - 1, y - 1 ));
            end
        end

        return newTiles;
    end

    local function createWorldObjects()
        local objectLayer = love.image.newImageData( 'res/data/maps/Map_Objects.png' );
        for x = 1, objectLayer:getWidth() do
            for y = 1, objectLayer:getHeight() do
                createWorldObject( tiles[x][y], objectLayer:getPixel( x - 1, y - 1 ));
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
