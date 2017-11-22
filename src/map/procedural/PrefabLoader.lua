---
-- This class handles the generation of procedural maps.
-- @module PrefabLoader
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )
local Util = require( 'src.util.Util' )
local Compressor = require( 'src.util.Compressor' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local PrefabLoader = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local PREFAB_SOURCE_FOLDER = 'res/data/procgen/prefabs/'
local PREFAB_MOD_FOLDER    = 'mods/maps/prefabs/'
local FILE_EXTENSION       = '.prefab'

-- ------------------------------------------------
-- Private Variables
-- ------------------------------------------------

local prefabs = {}

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Loads a prefab template.
-- @tparam  string  src The path to load the template from.
-- @treturn boolean     True if the prefab was loaded correctly.
-- @treturn table       The loaded prefabTemplate (only if successful).
--
local function load( src )
    return Compressor.load( src )
end

---
-- Loads prefabs from the provided path.
-- @tparam string sourceFolder The path to check.
--
local function loadPrefabTemplates( sourceFolder )
    local count = 0
    for _, item in ipairs( love.filesystem.getDirectoryItems( sourceFolder )) do
        if Util.getFileExtension( item ) == FILE_EXTENSION then
            local template = load( sourceFolder .. item )
            table.insert( prefabs[template.size], template )

            count = count + 1
            Log.print( string.format( '  %3d. %16s -> %16s (%s)', count, item, template.id, template.size ), 'PrefabLoader' )
        else
            Log.debug( string.format( 'Ignoring invalid file type: %s', item ), 'PrefabLoader' )
        end
    end
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Loads all prefab templates the game can find.
--
function PrefabLoader.load()
    -- Init prefab tables.
    prefabs.XS = {}
    prefabs.S  = {}
    prefabs.M  = {}
    prefabs.L  = {}
    prefabs.XL = {}

    Log.print( 'Loading vanilla parcel prefabs:', 'PrefabLoader' )
    loadPrefabTemplates( PREFAB_SOURCE_FOLDER )
    Log.print( 'Loading external parcel prefabs:', 'PrefabLoader' )
    loadPrefabTemplates( PREFAB_MOD_FOLDER )
end

function PrefabLoader.getPrefab( type )
    if not prefabs[type] then
        return false
    end
    return prefabs[type][love.math.random(#prefabs[type])]
end

return PrefabLoader
