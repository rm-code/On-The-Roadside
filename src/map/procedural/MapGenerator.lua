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

    local tileGrid
    local width, height

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

    local function placePrefabTiles( tiles, px, py, rotate )
        if rotate then
            tiles = ArrayRotation.rotate( tiles, rotate )
        end

        for tx = 1, #tiles do
            for ty = 1, #tiles[tx] do
                tileGrid[tx + px][ty + py] = createTile( tx + px, ty + py, tiles[tx][ty] )
            end
        end
    end

    local function placePrefabObjects( objects, px, py, rotate )
        if rotate then
            objects = ArrayRotation.rotate( objects, rotate )
        end

        for tx = 1, #objects do
            for ty = 1, #objects[tx] do
                if objects[tx][ty] then
                    tileGrid[tx + px][ty + py]:addWorldObject( WorldObjectFactory.create( objects[tx][ty] ))
                end
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

    local function fillParcels( parcels )
        for type, definitions in pairs( parcels ) do
            Log.debug( string.format( 'Placing %s parcels.', type ), 'MapGenerator' )

            for _, definition in ipairs( definitions ) do
                local prefab = PrefabLoader.getPrefab( type )
                if prefab then
                    local rotation = 0

                    -- Non square parcel layouts are only rotated by 90° if the parcel
                    -- layout is rotated.
                    if definition.h > definition.w then
                        rotation = 1
                    end

                    -- Get parcel coordinates.
                    local x = definition.x
                    local y = definition.y

                    -- Place tiles.
                    placePrefabTiles( prefab:getTiles(), (x-1) * PARCEL_SIZE.WIDTH, (y-1) * PARCEL_SIZE.HEIGHT, rotation )

                    -- Place objects.
                    placePrefabObjects( prefab:getObjects(), (x-1) * PARCEL_SIZE.WIDTH, (y-1) * PARCEL_SIZE.HEIGHT, rotation )
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

        width, height = layout.dimensions.width, layout.dimensions.height
        tileGrid = createTileGrid( width, height )

        fillParcels( layout.parcels )
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
