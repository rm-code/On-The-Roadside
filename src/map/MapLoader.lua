---
-- This class handles the loading of different maps.
-- @module MapLoader
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )
local Map = require( 'src.map.Map' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MapLoader = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local MAPS_SOURCE_FOLDER = 'res/data/maps/'

local INFO_FILE = 'info'
local GROUND_LAYER_FILE = 'Map_Ground.png'
local OBJECT_LAYER_FILE = 'Map_Objects.png'
local SPAWNS_LAYER_FILE = 'Map_Spawns.png'

-- ------------------------------------------------
-- Private Variables
-- ------------------------------------------------

local maps = {}

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Checks if the loaded info file provides all the necessary fields.
-- @tparam  table   infoFile The loaded file to check.
-- @treturn boolean          True if the module is valid.
--
local function validate( infoFile )
    if not infoFile.name
    or not infoFile.ground
    or not infoFile.objects
    or not infoFile.spawns then
        return false
    end
    return true
end

---
-- Loads a map template from its folder.
-- @tparam  string  src The path to load the template from.
-- @treturn boolean     True if the map was loaded correctly.
-- @treturn table       The loaded mapTemplate (only if successful).
--
local function load( src )
    local module = require( src .. INFO_FILE )
    if not module or not validate( module ) then
        Log.warn( string.format( 'Couldn\'t load map from %s. Bad format on info file.', src ), 'MapLoader' )
        return false
    end

    local mapTemplate = {}
    mapTemplate.info = module
    mapTemplate.ground = love.image.newImageData( src .. GROUND_LAYER_FILE )
    mapTemplate.object = love.image.newImageData( src .. OBJECT_LAYER_FILE )
    mapTemplate.spawns = love.image.newImageData( src .. SPAWNS_LAYER_FILE )
    return true, mapTemplate
end

---
-- Loads maps from the provided path.
-- @tparam string sourceFolder The path to check.
--
local function loadMaps( sourceFolder )
    local count = 0
    for _, item in ipairs( love.filesystem.getDirectoryItems( sourceFolder )) do
        local path = sourceFolder .. item .. '/'
        if love.filesystem.isDirectory( path ) then
            local success, mapTemplate = load( path )

            if success then
                local name = mapTemplate.info.name
                maps[name] = mapTemplate

                count = count + 1
                Log.debug( string.format( '  %3d. %s', count, name ))
            end
        end
    end
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Loads all map templates the game can find.
--
function MapLoader.load()
    Log.debug( 'Loading default maps:' )
    loadMaps( MAPS_SOURCE_FOLDER )
end

---
-- Creates a specific map.
-- @tparam  string name The name of the map to load.
-- @treturn Map         The newly created map.
--
function MapLoader.create( name )
    local mapTemplate = maps[name]

    local map = Map.new( mapTemplate.info, mapTemplate.ground, mapTemplate.object, mapTemplate.spawns )
    map:init()

    return map
end

---
-- Creates a map randomly chosen from the map template table.
-- @treturn Map The newly created map.
--
function MapLoader.createRandom()
    local rnd = {}
    for name, _ in pairs( maps ) do
        if name ~= 'base' then
            rnd[#rnd + 1] = name
        end
    end

    local name = rnd[love.math.random( #rnd )]
    return MapLoader.create( name )
end

return MapLoader
