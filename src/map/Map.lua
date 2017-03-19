local Observable = require( 'src.util.Observable' );
local TileFactory = require( 'src.map.tiles.TileFactory' );
local WorldObjectFactory = require( 'src.map.worldobjects.WorldObjectFactory' );
local ItemFactory = require( 'src.items.ItemFactory' );

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
local SPAWNS_LAYER = love.image.newImageData( 'res/data/maps/Map_Spawns.png' );

local TILE_SIZE = require( 'src.constants.TileSize' );

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Map.new()
    local self = Observable.new():addInstance( 'Map' );

    local tiles;
    local spawnpoints = {
        allied  = {},
        neutral = {},
        enemy   = {}
    };

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
    -- Creates a spawnpoint for the given Tile based on the pixel color read
    -- from the map's spawns layer.
    -- @param tile (Tile)   The Tile for which to create the spawnpoint.
    -- @param r    (number) The red-component read from the spawns layer.
    -- @param g    (number) The green-component read from the spawns layer.
    -- @param b    (number) The blue-component read from the spawns layer.
    -- @param a    (number) The alpha value read from the spawns layer.
    --
    local function createSpawnPoint( tile, r, g, b, a )
        if a == 0 then
            table.insert( spawnpoints.neutral, tile );
        end

        for _, info in ipairs( INFO_FILE.spawns ) do
            if info.r == r and info.g == g and info.b == b then
                table.insert( spawnpoints[info.type], tile );
                break;
            end
        end
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
    -- Iterates over the spawns layer's RGBA values pixel by pixel and creates
    -- spawn points based on the loaded colors.
    --
    local function createSpawnPoints()
        for x = 1, SPAWNS_LAYER:getWidth() do
            for y = 1, SPAWNS_LAYER:getHeight() do
                createSpawnPoint( tiles[x][y], SPAWNS_LAYER:getPixel( x - 1, y - 1 ));
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

    local function loadSavedTiles( savedmap )
        local loadedTiles = {};
        for _, tile in ipairs( savedmap ) do
            local x, y = tile.x, tile.y;
            loadedTiles[x] = loadedTiles[x] or {};
            loadedTiles[x][y] = TileFactory.create( x, y, tile.id );
            local newTile = loadedTiles[x][y];

            if tile.worldObject then
                local worldObject = WorldObjectFactory.create( tile.worldObject.id );
                worldObject:setHitPoints( tile.worldObject.hp );
                worldObject:setPassable( tile.worldObject.passable );
                worldObject:setBlocksVision( tile.worldObject.blocksVision );
                if worldObject:isContainer() and tile.worldObject.inventory then
                    worldObject:getInventory():loadItems( tile.worldObject.inventory );
                end
                newTile:addWorldObject( worldObject );
            end
            if tile.inventory then
                newTile:getInventory():loadItems( tile.inventory );
            end
            if tile.explored then
                for i, v in pairs( tile.explored ) do
                    newTile:setExplored( i, v );
                end
            end
        end
        return loadedTiles;
    end

    local function recreateMap( savedmap )
        tiles = loadSavedTiles( savedmap );
        addNeighbours();
    end

    local function createMap()
        tiles = createTiles();
        createWorldObjects();
        createSpawnPoints();
        addNeighbours();
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    ---
    -- Randomly searches for a tile on which a player could be spawned.
    -- @param faction (string) The faction identifier.
    -- @return        (Tile)   A tile suitable for spawning.
    --
    function self:findSpawnPoint( faction )
        while true do
            local x = love.math.random( 1, SPAWNS_LAYER:getWidth() );
            local y = love.math.random( 1, SPAWNS_LAYER:getHeight() );

            local tile = self:getTileAt( x, y );
            for _, spawn in ipairs( spawnpoints[faction] ) do
                if tile == spawn and tile:isPassable() and not tile:isOccupied() then
                    return tile;
                end
            end
        end
    end

    ---
    -- Initialises the map by creating the Tiles, creating references to the
    -- neighbouring tiles and adding WorldObjects.
    --
    function self:init( savegame )
        if savegame then
            recreateMap( savegame.map );
            return;
        end

        createMap();
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
                    -- Create items from the destroyed object.
                    for _, drop in ipairs( tile:getWorldObject():getDrops() ) do
                        local id, tries, chance = drop.id, drop.tries, drop.chance;
                        for _ = 1, tries do
                            if love.math.random( 100 ) < chance then
                                local item = ItemFactory.createItem( id );
                                tile:getInventory():addItem( item );
                            end
                        end
                    end

                    -- If the world object was a container drop the items in it.
                    if tile:getWorldObject():isContainer() and not tile:getWorldObject():getInventory():isEmpty() then
                        local items = tile:getWorldObject():getInventory():getItems();
                        for _, item in pairs( items ) do
                            tile:getInventory():addItem( item );
                        end
                    end

                    -- If the world object has a debris object, place that on the tile.
                    if tile:getWorldObject():getDebrisID() then
                        local nobj = WorldObjectFactory.create( tile:getWorldObject():getDebrisID() );
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

    ---
    -- Marks all tiles which have been explored by this faction as dirty.
    -- @param faction (string) The faction identifier.
    --
    function self:updateExplorationInfo( faction )
        for x = 1, #tiles do
            for y = 1, #tiles[x] do
                if tiles[x][y]:isExplored( faction ) then
                    tiles[x][y]:setDirty( true );
                end
            end
        end
    end

    function self:serialize()
        local t = {};
        for x = 1, #tiles do
            for y = 1, #tiles[x] do
                table.insert( t, tiles[x][y]:serialize() );
            end
        end
        return t;
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

    ---
    -- Returns the width and height of the map in pixels.
    -- @return (number) The width of the map.
    -- @return (number) The height of the map.
    --
    function self:getPixelDimensions()
        return GROUND_LAYER:getWidth() * TILE_SIZE, GROUND_LAYER:getHeight() * TILE_SIZE;
    end

    return self;
end

return Map;
