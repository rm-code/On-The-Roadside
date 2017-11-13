---
-- This class handles the generation of procedural maps.
-- @module PrefabLoader
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )
local Bitser = require( 'lib.Bitser' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local PrefabLoader = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local PREFAB_SOURCE_FOLDER = 'res/data/procgen/prefabs/'
local PREFAB_MOD_FOLDER    = 'mods/maps/prefabs/'

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
    return Bitser.loadLoveFile( src )
end

---
-- Loads prefabs from the provided path.
-- @tparam string sourceFolder The path to check.
--
local function loadPrefabTemplates( sourceFolder )
    local count = 0
    for _, item in ipairs( love.filesystem.getDirectoryItems( sourceFolder )) do
        local template = load( sourceFolder .. item )
        table.insert( prefabs[template.size], template )

        count = count + 1
        Log.debug( string.format( '  %3d. %s -> %s (%s)', count, item, template.name, type ))
    end
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Loads all prefab templates the game can find.
--
function PrefabLoader.load()
    Log.debug( 'Loading parcel prefabs:' )

    -- Init prefab tables.
    prefabs.XS = {}
    prefabs.S  = {}
    prefabs.M  = {}
    prefabs.L  = {}
    prefabs.XL = {}

    loadPrefabTemplates( PREFAB_SOURCE_FOLDER )
    loadPrefabTemplates( PREFAB_MOD_FOLDER )
end

function PrefabLoader.getPrefab( type )
    if not prefabs[type] then
        return false
    end
    return prefabs[type][love.math.random(#prefabs[type])]
end

return PrefabLoader
