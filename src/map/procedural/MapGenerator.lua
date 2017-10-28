---
-- This class handles the generation of procedural maps.
-- @module MapGenerator
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

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MapGenerator = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local LAYOUTS_SOURCE_FOLDER = 'res/data/procgen/layouts/'

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
        local path = sourceFolder .. item
        local layout = love.filesystem.load( path )
        layouts[#layouts + 1] = layout()

        count = count + 1
        Log.debug( string.format( '  %3d. %s', count, item ))
    end
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

function MapGenerator.load()
    Log.debug( 'Loading parcel layouts:' )
    loadLayoutTemplates( LAYOUTS_SOURCE_FOLDER )
end

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function MapGenerator.new()
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
        allied = {}
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
        local tiles = prefab:getTiles()
        local objects = prefab:getObjects()

        if rotate then
            tiles = ArrayRotation.rotate( tiles, rotate )
            objects = ArrayRotation.rotate( objects, rotate )
        end

        for tx = 1, #tiles do
            for ty = 1, #tiles[tx] do
                tileGrid[tx + px][ty + py] = createTile( tx + px, ty + py, tiles[tx][ty] )

                -- The object grid can contain empty tiles.
                if objects[tx][ty] then
                    tileGrid[tx + px][ty + py]:addWorldObject( WorldObjectFactory.create( objects[tx][ty] ))
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
            Log.debug( string.format( 'Placing %s parcels.', type ), 'MapGenerator' )

            for _, definition in ipairs( definitions ) do
                parcelGrid:addParcels( definition.x, definition.y, definition.w, definition.h, type )

                local prefab = PrefabLoader.getPrefab( type )
                if prefab then
                    local rotation = rotateParcels( definition.w, definition.h )

                    -- Get parcel coordinates.
                    local x = definition.x
                    local y = definition.y

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
            if parcel:getType() ~= 'foliage' then
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
        return tiles
    end

    ---
    -- Create spawnpoints.
    -- TODO Proper implementation.
    --
    local function createSpawnPoints( spawns )
        for _, definition in ipairs( spawns ) do
            local x, y = definition.x * PARCEL_SIZE.WIDTH, definition.y * PARCEL_SIZE.HEIGHT

            for w = 0, PARCEL_SIZE.WIDTH-1 do
                for h = 0, PARCEL_SIZE.HEIGHT-1 do
                    spawnpoints.allied[#spawnpoints.allied + 1] = tileGrid[x+w][y+h]
                end
            end
        end
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init()
        -- Select random layout.
        local layout = layouts[love.math.random( #layouts )]

        -- Generate empty parcel grid.
        parcelGrid = ParcelGrid.new()
        parcelGrid:init( layout.dimensions.width, layout.dimensions.height )

        -- Generate empty tile grid.
        width, height = layout.dimensions.width, layout.dimensions.height
        tileGrid = createTileGrid( width, height )

        fillParcels( layout.parcels )

        parcelGrid:createNeighbours()

        spawnFoliage()

        createSpawnPoints( layout.parcels.spawns )
    end

    function self:getSpawnpoints()
        return spawnpoints
    end

    function self:getTiles()
        return tileGrid
    end

    function self:getTileGridDimensions()
        return width * PARCEL_SIZE.WIDTH, height * PARCEL_SIZE.HEIGHT
    end

    return self
end

return MapGenerator
