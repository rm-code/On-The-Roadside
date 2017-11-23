---
-- This class handles the generation of procedural maps.
-- @module ProceduralMapGenerator
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )
local ArrayRotation = require( 'src.util.ArrayRotation' )
local PrefabLoader = require( 'src.map.procedural.PrefabLoader' )
local ParcelGrid = require( 'src.map.procedural.ParcelGrid' )
local TileFactory = require( 'src.map.tiles.TileFactory' )
local WorldObjectFactory = require( 'src.map.worldobjects.WorldObjectFactory' )
local Util = require( 'src.util.Util' )
local Compressor = require( 'src.util.Compressor' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ProceduralMapGenerator = {}

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

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

function ProceduralMapGenerator.load()
    Log.print( 'Loading vanilla layouts:', 'ProceduralMapGenerator' )
    loadLayoutTemplates( LAYOUTS_SOURCE_FOLDER )

    Log.print( 'Loading external layouts:', 'ProceduralMapGenerator' )
    loadLayoutTemplates( LAYOUTS_MODS_FOLDER )
end

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function ProceduralMapGenerator.new()
    local self = {}

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    -- The actual tile map.
    local tileGrid
    local width, height

    -- The parcel layout.
    local parcelGrid

    -- Spawnpoints.
    local spawnpoints = {
        allied = {},
        neutral = {},
        enemy = {}
    }

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

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
    -- Places the tiles and world objects belonging to this prefab.
    -- @tparam Prefab prefab The prefab to place.
    -- @tparam number px     The starting coordinates along the x-axis for this prefab.
    -- @tparam number py     The starting coordinates along the y-axis for this prefab.
    -- @tparam number rotate The rotation to apply to the prefab before placing it.
    --
    local function placePrefab( prefab, px, py, rotate )
        local tiles = prefab.grid

        if rotate then
            tiles = ArrayRotation.rotate( tiles, rotate )
        end

        for tx = 1, #tiles do
            for ty = 1, #tiles[tx] do
                if tiles[tx][ty].tile then
                    tileGrid[tx + px][ty + py] = createTile( tx + px, ty + py, tiles[tx][ty].tile )
                end

                if tiles[tx][ty].worldObject then
                    tileGrid[tx + px][ty + py]:addWorldObject( WorldObjectFactory.create( tiles[tx][ty].worldObject ))
                end
            end
        end
    end

    ---
    -- Determines a random rotation for a certain parcel layout.
    -- @tparam  number pw The parcel's width.
    -- @tparam  number ph The parcel's height.
    -- @treturn number    The rotation direction [0, 3].
    --
    local function rotateParcels( pw, ph )
        -- Square parcels can be rotated in all directions.
        if pw == ph then
            return love.math.random( 0, 3 )
        end

        -- Handle rotation for rectangular parcels.
        if pw < ph then
            return love.math.random() > 0.5 and 1 or 3
        elseif pw > ph then
            return love.math.random() > 0.5 and 0 or 2
        end
    end

    ---
    -- Iterates over the parcel definitions for this map layout and tries to
    -- place prefabs for each of them.
    -- @tparam table parcels The parcel definitions.
    --
    local function fillParcels( parcels )
        for type, definitions in pairs( parcels ) do
            Log.debug( string.format( 'Placing %s parcels.', type ), 'ProceduralMapGenerator' )

            for _, definition in ipairs( definitions ) do
                -- Start coordinates at 0,0.
                local x, y, w, h = definition.x-1, definition.y-1, definition.w, definition.h
                parcelGrid:addParcels( x, y, w, h, type )

                local prefab = PrefabLoader.getPrefab( type )
                if prefab then
                    local rotation = rotateParcels( definition.w, definition.h )

                    -- Place tiles and worldobjects.
                    placePrefab( prefab, x * PARCEL_SIZE.WIDTH, y * PARCEL_SIZE.HEIGHT, rotation )
                end
            end
        end
    end

    ---
    -- Spawns trees in designated parcels.
    --
    local function spawnFoliage()
        parcelGrid:iterate( function( parcel, x, y )
            if parcel:getType() ~= 'FOLIAGE' then
                return
            end

            local n = parcel:getNeighbourCount()

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
    --
    local function spawnRoads()
        parcelGrid:iterate( function( parcel, x, y )
            if parcel:getType() ~= 'ROAD' then
                return
            end

            local tx, ty = x * PARCEL_SIZE.WIDTH, y * PARCEL_SIZE.HEIGHT
            for w = 1, PARCEL_SIZE.WIDTH do
                for h = 1, PARCEL_SIZE.HEIGHT do
                    tileGrid[tx + w][ty + h] = createTile( tx + w, ty + h, 'tile_asphalt' )
                end
            end
        end)
    end

    ---
    -- Creates an empty tile grid.
    -- @tparam number w The width of the grid in parcels.
    -- @tparam number h The height of the grid in parcels.
    -- @tparam table    The new tile grid.
    --
    local function createTileGrid( w, h )
        local tiles = {}
        for x = 1, w * PARCEL_SIZE.WIDTH do
            tiles[x] = {}
            for y = 1, h * PARCEL_SIZE.HEIGHT do
                -- TODO Better algorithm for placing ground tiles.
                local id = love.math.random() > 0.7 and 'tile_soil' or 'tile_grass'
                tiles[x][y] = createTile( x, y, id )
            end
        end
        return tiles, w * PARCEL_SIZE.WIDTH, h * PARCEL_SIZE.HEIGHT
    end

    ---
    -- Create spawnpoints.
    -- TODO Proper implementation.
    --
    local function createSpawnPoints( spawns )
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
                        spawnpoints[target][#spawnpoints[target] + 1] = tileGrid[x+w][y+h]
                    end
                end
            end
        end
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init( nlayout )
        -- Use specific layout or select a random one.
        local layout = nlayout or layouts[love.math.random( #layouts )]

        -- Generate empty parcel grid.
        parcelGrid = ParcelGrid.new()
        parcelGrid:init( layout.mapwidth, layout.mapheight )

        -- Generate empty tile grid.
        tileGrid, width, height = createTileGrid( layout.mapwidth, layout.mapheight )

        fillParcels( layout.prefabs )

        parcelGrid:createNeighbours()

        spawnRoads()
        spawnFoliage()
        createSpawnPoints( layout.spawns )
    end

    function self:getSpawnpoints()
        return spawnpoints
    end

    function self:getTiles()
        return tileGrid
    end

    function self:getTileGridDimensions()
        return width, height
    end

    return self
end

return ProceduralMapGenerator
