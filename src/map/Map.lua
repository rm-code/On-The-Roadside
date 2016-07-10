local Observable = require( 'src.util.Observable' );
local TileFactory = require( 'src.map.tiles.TileFactory' );
local WorldObjectFactory = require( 'src.map.worldobjects.WorldObjectFactory' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Map = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local DIRECTION = require( 'src.constants.Direction' );

local INFO_FILE = love.filesystem.load( 'res/data/maps/info.lua' )();
local GROUND_LAYER = love.image.newImageData( 'res/data/maps/Map_Ground.png' );
local OBJECT_LAYER = love.image.newImageData( 'res/data/maps/Map_Objects.png' );

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Map.new()
    local self = Observable.new():addInstance( 'Map' );

    local tiles;

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    ---
    -- Creates a Tile at the given coordinates based on the pixel color read
    -- from the map's ground layer.
    -- @param x (number) The tile's coordinate along the x-axis.
    -- @param y (number) The tile's coordinate along the y-axis.
    -- @param r (number) The red-component read from the ground layer.
    -- @param g (number) The green-component read from the ground layer.
    -- @param b (number) The blue-component read from the ground layer.
    -- @param a (number) The alpha value read from the ground layer.
    -- @return  (Tile)   The new Tile object.
    --
    local function createTile( x, y, r, g, b, a )
        if a ~= 255 then
            error( 'The ground layer must only contain fully opaque pixels!' );
        end

        local tile;
        for _, info in ipairs( INFO_FILE.ground ) do
            if info.r == r and info.g == g and info.b == b then
                tile = info.tile;
                break;
            end
        end
        return TileFactory.create( x, y, tile );
    end

    ---
    -- Creates a WorldObject on the given Tile based on the pixel color read
    -- from the map's object layer.
    -- @param tile (Tile)   The Tile on which to place the WorldObject.
    -- @param r    (number) The red-component read from the object layer.
    -- @param g    (number) The green-component read from the object layer.
    -- @param b    (number) The blue-component read from the object layer.
    -- @param a    (number) The alpha value read from the object layer.
    --
    local function createWorldObject( tile, r, g, b, a )
        if a == 0 then
            return;
        elseif a ~= 255 then
            error( 'The object layer must only contain either fully opaque or fully transparent pixels!' );
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

    ---
    -- Iterates over the ground layer's RGBA values pixel by pixel and creates
    -- tiles based on the loaded colors.
    -- @return (table) A 2d array containing the map's tiles.
    --
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

    ---
    -- Iterates over the object layer's RGBA values pixel by pixel and creates
    -- WorldObjects based on the loaded colors.
    --
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
    -- Public Methods
    -- ------------------------------------------------

    ---
    -- Randomly searches for a tile on which a player could be spawned.
    -- @return (Tile) A tile suitable for spawning or nil.
    --
    function self:findRandomSpawnPoint()
        while true do
            local x = love.math.random( 1, GROUND_LAYER:getWidth() );
            local y = love.math.random( 1, GROUND_LAYER:getHeight() );

            local tile = self:getTileAt( x, y );
            if tile:isPassable() and not tile:isOccupied() then
                return tile;
            end
        end
    end

    ---
    -- Initialises the map by creating the Tiles, creating references to the
    -- neighbouring tiles and adding WorldObjects.
    --
    function self:init()
        tiles = createTiles();
        createWorldObjects();
        addNeighbours();
    end

    ---
    -- Iterates over all tiles and performs the callback function on them.
    -- @param callback (function) The operation to perform on each tile.
    --
    function self:iterate( callback )
        for x = 1, #tiles do
            for y = 1, #tiles[x] do
                callback( tiles[x][y], x, y );
            end
        end
    end

    ---
    -- Updates the map. This resets the visibility attribute for all visible
    -- tiles and marks them for a drawing update. It also replaces destroyed
    -- WorldObjects with their debris types or removes them completely.
    --
    function self:update()
        for x = 1, #tiles do
            for y = 1, #tiles[x] do
                local tile = tiles[x][y];
                if tile:hasWorldObject() and tile:getWorldObject():isDestroyed() then
                    if tile:getWorldObject():getDebrisType() then
                        local nobj = WorldObjectFactory.create( tile:getWorldObject():getDebrisType() );
                        tile:removeWorldObject();
                        tile:addWorldObject( nobj );
                    else
                        tile:removeWorldObject();
                    end
                    self:publish( 'TILE_UPDATED', tile );
                end
            end
        end
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    ---
    -- Returns the Tile at the given coordinates.
    -- @param x (number) The position along the x-axis.
    -- @param y (number) The position along the y-axis.
    -- @return  (Tile)   The Tile at the given position.
    --
    function self:getTileAt( x, y )
        return tiles[x] and tiles[x][y];
    end

    return self;
end

return Map;
