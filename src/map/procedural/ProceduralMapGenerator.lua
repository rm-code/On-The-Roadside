---
-- This class handles the generation of procedural maps.
-- @module ProceduralMapGenerator
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local Log = require( 'src.util.Log' )
local ArrayRotation = require( 'lib.ArrayRotation' )
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
-- @tparam Map    map    The map to place the prefab on.
-- @tparam Prefab prefab The prefab to place.
-- @tparam number px     The starting coordinates along the x-axis for this prefab.
-- @tparam number py     The starting coordinates along the y-axis for this prefab.
--
local function placePrefab( map, prefab, px, py )
    -- Rotate prefab randomly.
    local tiles = ArrayRotation.rotate( prefab.grid, love.math.random( 0, 3 ))

    for tx = 1, #tiles do
        for ty = 1, #tiles[tx] do
            local mapX, mapY = tx + px, ty + py

            if tiles[tx][ty].tile then
                map:setTileAt( mapX, mapY, TileFactory.create( tiles[tx][ty].tile ))
            end

            if tiles[tx][ty].worldObject then
                map:setWorldObjectAt( mapX, mapY, WorldObjectFactory.create( tiles[tx][ty].worldObject ))
            end
        end
    end
end

---
-- Iterates over the parcel definitions for this map layout and tries to
-- place prefabs for each of them.
-- @tparam Map        map        The map to place the prefab on.
-- @tparam ParcelGrid parcelGrid The parcel grid to fill.
-- @tparam table      parcels    The parcel definitions.
--
local function fillParcels( map, parcelGrid, parcels )
    for type, definitions in pairs( parcels ) do
        Log.debug( string.format( 'Placing %s parcels.', type ), 'ProceduralMapGenerator' )

        for _, definition in ipairs( definitions ) do
            -- Start coordinates at 0,0.
            local x, y, w, h = definition.x-1, definition.y-1, definition.w, definition.h
            parcelGrid:addPrefab( x, y, w, h, type )

            local prefab = PrefabLoader.getPrefab( type )
            if prefab then
                -- Place tiles and worldobjects.
                placePrefab( map, prefab, x * PARCEL_SIZE.WIDTH, y * PARCEL_SIZE.HEIGHT )
            end
        end
    end
end

---
-- Spawns trees in designated parcels.
-- @tparam Map        map        The map to place the prefab on.
-- @tparam ParcelGrid parcelGrid The parcel grid to read the parcel definitions from.
--
local function spawnFoliage( map, parcelGrid )
    parcelGrid:iterate( function( parcel, x, y )
        if parcel:getType() ~= 'FOLIAGE' then
            return
        end

        local n = parcel:countNeighbours()

        local tx, ty = x * PARCEL_SIZE.WIDTH, y * PARCEL_SIZE.HEIGHT
        for px = 1, PARCEL_SIZE.WIDTH do
            for py = 1, PARCEL_SIZE.HEIGHT do
                local mapX, mapY = tx + px, ty + py

                -- Increase density based on count of neighbouring foliage tiles.
                if love.math.random() < n/10 then
                    map:setWorldObjectAt( mapX, mapY, WorldObjectFactory.create( 'worldobject_tree' ))
                end
            end
        end
    end)
end

---
-- Spawns roads in designated parcels.
-- TODO Replace with prefab based system.
-- @tparam Map        map        The map to place the prefab on.
-- @tparam ParcelGrid parcelGrid The parcel grid to read the parcel definitions from.
--
local function spawnRoads( map, parcelGrid )
    parcelGrid:iterate( function( parcel, x, y )
        if parcel:getType() ~= 'ROAD' then
            return
        end

        local tx, ty = x * PARCEL_SIZE.WIDTH, y * PARCEL_SIZE.HEIGHT
        for w = 1, PARCEL_SIZE.WIDTH do
            for h = 1, PARCEL_SIZE.HEIGHT do
                local mapX, mapY = tx + w, ty + h
                map:setTileAt( mapX, mapY, TileFactory.create( 'tile_asphalt' ))
            end
        end
    end)
end

---
-- Fills the map randomly with dirt and grass tiles.
-- @tparam Map map The map to fill.
--
local function fillMap( map, width, height )
    for x = 1, width do
        for y = 1, height do
            -- TODO Better algorithm for placing ground tiles.
            local id = love.math.random() > 0.7 and 'tile_soil' or 'tile_grass'
            map:setTileAt( x, y, TileFactory.create( id ))
        end
    end
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

    -- Spawnpoints.
    self.spawnpoints = {
        allied = {},
        neutral = {},
        enemy = {}
    }

    fillMap( map, map:getDimensions() )
    fillParcels( map, self.parcelGrid, self.layout.prefabs )

    spawnRoads( map, self.parcelGrid )
    spawnFoliage( map, self.parcelGrid )
    createSpawnPoints( self.spawnpoints, self.layout.spawns )

    map:setSpawnpoints( self.spawnpoints )

    return map
end

return ProceduralMapGenerator
