---
-- This class handles the generation of procedural maps.
-- @module ProceduralMapGenerator
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local Log = require( 'src.util.Log' )
local ArrayRotation = require( 'src.util.ArrayRotation' )
local PrefabLoader = require( 'src.map.procedural.PrefabLoader' )
local ParcelGrid = require( 'src.map.procedural.ParcelGrid' )
local TileFactory = require( 'src.map.tiles.TileFactory' )
local WorldObjectFactory = require( 'src.map.worldobjects.WorldObjectFactory' )
local Util = require( 'src.util.Util' )
local Compressor = require( 'src.util.Compressor' )
local Map = require( 'src.map.Map' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ProceduralMapGenerator = Class( 'ProceduralMapGenerator' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local LAYOUTS_SOURCE_FOLDER = 'res/data/procgen/layouts/'
local LAYOUTS_MODS_FOLDER = 'mods/maps/layouts/'

local FILE_EXTENSION = '.layout'

local PARCEL_SIZE = require( 'src.constants.PARCEL_SIZE' )

-- ------------------------------------------------
-- Private Variables
-- ------------------------------------------------

local layouts = {}

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Loads parcel layouts from the provided path.
-- @tparam string sourceFolder The path to check.
--
local function loadLayoutTemplates( sourceFolder )
    local count = 0
    for _, item in ipairs( love.filesystem.getDirectoryItems( sourceFolder )) do
        if Util.getFileExtension( item ) == FILE_EXTENSION then
            layouts[#layouts + 1] = Compressor.load( sourceFolder .. item )

            count = count + 1
            Log.print( string.format( '  %3d. %s', count, item ), 'ProceduralMapGenerator')
        else
            Log.debug( string.format( 'Ignoring invalid file type: %s', item ), 'ProceduralMapGenerator' )
        end
    end
end

---
-- Places the tiles and world objects belonging to this prefab.
-- @tparam table  tileGrid The tile grid to place the prefab on.
-- @tparam Prefab prefab   The prefab to place.
-- @tparam number px       The starting coordinates along the x-axis for this prefab.
-- @tparam number py       The starting coordinates along the y-axis for this prefab.
--
local function placePrefab( tileGrid, prefab, px, py )
    -- Rotate prefab randomly.
    local tiles = ArrayRotation.rotate( prefab.grid, love.math.random( 0, 3 ))

    for tx = 1, #tiles do
        for ty = 1, #tiles[tx] do
            if tiles[tx][ty].tile then
                tileGrid[tx + px][ty + py] = TileFactory.create( tx + px, ty + py, tiles[tx][ty].tile )
            end

            if tiles[tx][ty].worldObject then
                tileGrid[tx + px][ty + py]:addWorldObject( WorldObjectFactory.create( tiles[tx][ty].worldObject ))
            end
        end
    end
end

---
-- Iterates over the parcel definitions for this map layout and tries to
-- place prefabs for each of them.
-- @tparam table      tileGrid   The tile grid to place the prefab on.
-- @tparam ParcelGrid parcelGrid The parcel grid to fill.
-- @tparam table      parcels    The parcel definitions.
--
local function fillParcels( tileGrid, parcelGrid, parcels )
    for type, definitions in pairs( parcels ) do
        Log.debug( string.format( 'Placing %s parcels.', type ), 'ProceduralMapGenerator' )

        for _, definition in ipairs( definitions ) do
            -- Start coordinates at 0,0.
            local x, y, w, h = definition.x-1, definition.y-1, definition.w, definition.h
            parcelGrid:addPrefab( x, y, w, h, type )

            local prefab = PrefabLoader.getPrefab( type )
            if prefab then
                -- Place tiles and worldobjects.
                placePrefab( tileGrid, prefab, x * PARCEL_SIZE.WIDTH, y * PARCEL_SIZE.HEIGHT )
            end
        end
    end
end

---
-- Spawns trees in designated parcels.
-- @tparam ParcelGrid parcelGrid The parcel grid to read the parcel definitions from.
-- @tparam table      tileGrid   The tile grid to fill.
--
local function spawnFoliage( parcelGrid, tileGrid )
    parcelGrid:iterate( function( parcel, x, y )
        if parcel:getType() ~= 'FOLIAGE' then
            return
        end

        local n = parcel:countNeighbours()

        local tx, ty = x * PARCEL_SIZE.WIDTH, y * PARCEL_SIZE.HEIGHT
        for w = 1, PARCEL_SIZE.WIDTH do
            for h = 1, PARCEL_SIZE.HEIGHT do

                -- Increase density based on count of neighbouring foliage tiles.
                if love.math.random() < n/10 then
                    tileGrid[tx + w][ty + h]:addWorldObject( WorldObjectFactory.create( 'worldobject_tree' ))
                end
            end
        end
    end)
end

---
-- Spawns roads in designated parcels.
-- TODO Replace with prefab based system.
-- @tparam ParcelGrid parcelGrid The parcel grid to read the parcel definitions from.
-- @tparam table      tileGrid   The tile grid to fill.
--
local function spawnRoads( parcelGrid, tileGrid )
    parcelGrid:iterate( function( parcel, x, y )
        if parcel:getType() ~= 'ROAD' then
            return
        end

        local tx, ty = x * PARCEL_SIZE.WIDTH, y * PARCEL_SIZE.HEIGHT
        for w = 1, PARCEL_SIZE.WIDTH do
            for h = 1, PARCEL_SIZE.HEIGHT do
                tileGrid[tx + w][ty + h] = TileFactory.create( tx + w, ty + h, 'tile_asphalt' )
            end
        end
    end)
end

---
-- Creates an empty tile grid.
-- @tparam  number w The grid's width in tiles.
-- @tparam  number h The grid's height in tiles.
-- @treturn table    The new tile grid.
--
local function createTileGrid( w, h )
    local tiles = {}
    for x = 1, w do
        tiles[x] = {}
        for y = 1, h do
            -- TODO Better algorithm for placing ground tiles.
            local id = love.math.random() > 0.7 and 'tile_soil' or 'tile_grass'
            tiles[x][y] = TileFactory.create( x, y, id )
        end
    end
    return tiles
end

---
-- Create spawnpoints.
-- TODO Proper implementation.
-- @tparam table spawnpoints The table filled with the spawnpoint definitions.
-- @tparam table spawns      The table containing the spawn definitions.
--
local function createSpawnPoints( spawnpoints, spawns )
    for type, definitions in pairs( spawns ) do

        local target
        if type == 'SPAWNS_FRIENDLY' then
            target = 'allied'
        elseif type == 'SPAWNS_NEUTRAL' then
            target = 'neutral'
        elseif type == 'SPAWNS_ENEMY' then
            target = 'enemy'
        end

        for _, definition in ipairs( definitions ) do
            local x, y = (definition.x-1) * PARCEL_SIZE.WIDTH, (definition.y-1) * PARCEL_SIZE.HEIGHT

            for w = 1, PARCEL_SIZE.WIDTH do
                for h = 1, PARCEL_SIZE.HEIGHT do
                    spawnpoints[target][#spawnpoints[target] + 1] = { x = x+w, y = y+h }
                end
            end
        end
    end
end

-- ------------------------------------------------
-- Static Functions
-- ------------------------------------------------

---
-- Loads the map layouts from the game's source files and the mod directory.
--
function ProceduralMapGenerator.static:load()
    Log.print( 'Loading vanilla layouts:', 'ProceduralMapGenerator' )
    loadLayoutTemplates( LAYOUTS_SOURCE_FOLDER )

    Log.print( 'Loading external layouts:', 'ProceduralMapGenerator' )
    loadLayoutTemplates( LAYOUTS_MODS_FOLDER )
end

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- Creates a new procedural map
-- @tparam  table layout The layout definition to use for map creation (optional).
-- @treturn Map          The newly generated map.
--
function ProceduralMapGenerator:createMap( layout )
    -- Use specific layout or select a random one.
    self.layout = layout or Util.pickRandomValue( layouts )

    -- Calculate the size of the tile grid.
    self.width, self.height = self.layout.mapwidth * PARCEL_SIZE.WIDTH, self.layout.mapheight * PARCEL_SIZE.HEIGHT

    -- Create an empty map.
    local map = Map( self.width, self.height )

    -- Generate empty parcel grid.
    self.parcelGrid = ParcelGrid( self.layout.mapwidth, self.layout.mapheight )
    self.parcelGrid:createNeighbours()

    self.width, self.height = self.layout.mapwidth * PARCEL_SIZE.WIDTH, self.layout.mapheight * PARCEL_SIZE.HEIGHT

    -- The actual tile map.
    self.tileGrid = createTileGrid( self.width, self.height )

    -- Spawnpoints.
    self.spawnpoints = {
        allied = {},
        neutral = {},
        enemy = {}
    }

    fillParcels( self.tileGrid, self.parcelGrid, self.layout.prefabs )

    spawnRoads( self.parcelGrid, self.tileGrid )
    spawnFoliage( self.parcelGrid, self.tileGrid )
    createSpawnPoints( self.spawnpoints, self.layout.spawns )

    map:setTiles( self.tileGrid )
    map:setSpawnpoints( self.spawnpoints )

    return map
end

return ProceduralMapGenerator
