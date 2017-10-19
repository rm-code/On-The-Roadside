---
-- This class handles the generation of procedural maps.
-- @module MapGenerator
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Util = require( 'src.util.Util' )
local ArrayRotation = require( 'src.util.ArrayRotation' )
local PrefabLoader = require( 'src.map.procedural.PrefabLoader' )
local ParcelGrid = require( 'src.map.procedural.ParcelGrid' )
local TileFactory = require( 'src.map.tiles.TileFactory' )
local WorldObjectFactory = require( 'src.map.worldobjects.WorldObjectFactory' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MapGenerator = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local PARCEL_SIZE = require( 'src.constants.PARCEL_SIZE' )
local PARCEL_GRID_SIZE = {
    { w =  8,   h =  8 },
    { w =  16,  h =  16 }
}

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function MapGenerator.new()
    local self = {}

    local size
    local parcelGrid
    local tileGrid

    ---
    -- Creates a Tile at the given coordinates.
    -- @tparam  number x    The tile's coordinate along the x-axis.
    -- @tparam  number y    The tile's coordinate along the y-axis.
    -- @tparam  string tile The tile's id.
    -- @treturn Tile        The new Tile object.
    --
    local function createTile( x, y, tile )
        return TileFactory.create( x, y, tile )
    end

    ---
    -- Checks all parcels touched by the prefab for validity.
    -- @tparam  number  x  The x coordinate where the prefab placement starts.
    -- @tparam  number  y  The y coordinate where the prefab placement starts.
    -- @tparam  number  pw The number of parcels to check horizontally.
    -- @tparam  number  ph The number of parcels to check vertically.
    -- @treturn boolean    Wether the spawnpoint is valid for this prefab.
    --
    local function checkSpawn( x, y, pw, ph )
        -- Check all parcels in the prefab's grid. The width and height are used
        -- as an offset to the spawnpoint. Since the spawnpoint itself should
        -- contain the first parcel of the prefab the offset needs to start at 0.
        for w = 0, pw-1 do
            for h = 0, ph-1 do
                local parcel = parcelGrid:getParcelAt( x + w, y + h )

                -- Parcel outside of the grid.
                if not parcel then
                    return false
                end

                if not parcel:isValid() then
                    return false
                end
            end
        end
        return true
    end

    ---
    -- Places the prefab's parcels in the map's parcel grid.
    --
    local function placePrefabParcels( x, y, pw, ph )
        for w = 0, pw-1 do
            for h = 0, ph-1 do
                local parcel = parcelGrid:getParcelAt( x + w, y + h )
                parcel:setOccupied( true )
            end
        end
    end

    local function createTileGrid( w, h )
        local tiles = {}
        for x = 1, w * PARCEL_SIZE.WIDTH do
            tiles[x] = {}
            for y = 1, h * PARCEL_SIZE.HEIGHT do
                local id = love.math.random() > 0.7 and 'tile_soil' or 'tile_grass'
                tiles[x][y] = createTile( x, y, id )
            end
        end
        return tiles
    end

    local function placePrefabTiles( tiles, px, py, rotate )
        tiles = ArrayRotation.rotate( tiles, rotate )

        for tx = 1, #tiles do
            for ty = 1, #tiles[tx] do
                tileGrid[tx + px][ty + py] = createTile( tx + px, ty + py, tiles[tx][ty] )
            end
        end
    end

    local function placePrefabObjects( objects, px, py, rotate )
        objects = ArrayRotation.rotate( objects, rotate )

        for tx = 1, #objects do
            for ty = 1, #objects[tx] do
                if objects[tx][ty] then
                    tileGrid[tx + px][ty + py]:addWorldObject( WorldObjectFactory.create( objects[tx][ty] ))
                end
            end
        end
    end

    function self:init()
        -- Select random parcel grid size.
        size = PARCEL_GRID_SIZE[love.math.random(#PARCEL_GRID_SIZE)]

        -- Create parcel grid.
        parcelGrid = ParcelGrid.new( size.w, size.h )
        parcelGrid:init()

        tileGrid = createTileGrid( size.w, size.h )
    end

    function self:createParcels()
        for _ = 1, 20000 do
            self:spawnPrefabs()
        end
    end

    function self:spawnPrefabs()
        local prefab = PrefabLoader.getRandomPrefab()
        local pw, ph = prefab:getParcelDimensions()

        local rotate = 0

        if prefab:isSquare() then
            rotate = love.math.random(0, 3)
        else
            -- Non square parcel layouts are only rotated by 90°.
            if love.math.random() > 0.5 then
                pw, ph = Util.swap( pw, ph )
                rotate = love.math.random() > 0.5 and 1 or 3
            else
                rotate = love.math.random() > 0.5 and 0 or 2
            end
        end

        -- Get random coordinates on the parcel grid.
        local x = love.math.random( parcelGrid:getWidth() )
        local y = love.math.random( parcelGrid:getHeight() )

        local valid = checkSpawn( x, y, pw, ph )
        if valid then
            placePrefabParcels( x, y, pw, ph )

            -- Place tiles.
            placePrefabTiles( prefab:getTiles(), (x-1) * PARCEL_SIZE.WIDTH, (y-1) * PARCEL_SIZE.HEIGHT, rotate )

            -- Place objects.
            placePrefabObjects( prefab:getObjects(), (x-1) * PARCEL_SIZE.WIDTH, (y-1) * PARCEL_SIZE.HEIGHT, rotate )
        end
    end

    function self:getParcelGrid()
        return parcelGrid
    end

    function self:getTiles()
        return tileGrid
    end

    function self:getTileGridDimensions()
        return size.w * PARCEL_SIZE.WIDTH, size.h * PARCEL_SIZE.HEIGHT
    end

    return self
end

return MapGenerator
