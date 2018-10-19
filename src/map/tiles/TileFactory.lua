---
-- The TileFactory takes care of loading templates for all tiles in the game
-- and provides a public function for creating tiles based on their ID.
-- @module TileFactory
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )
local Tile = require( 'src.map.tiles.Tile' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local TileFactory = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TEMPLATE_FILE  = 'res.data.Tiles'

-- ------------------------------------------------
-- Private Variables
-- ------------------------------------------------

local templates = {}

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Loads all templates found in the specified file.
-- @tparam string src The path to load the templates from.
-- @treturn table The table containing all the loaded templates.
--
local function load( src )
    local module = require( src )

    local tiles = {}
    for _, template in ipairs( module ) do
        tiles[template.id] = template
    end
    return tiles
end

---
-- Counts all items in the table.
-- @tparam table t The table in which to count the items.
-- @treturn number The amount of items in the table.
--
local function countTemplates( t )
    local counter = 0
    for _, _ in pairs( t ) do
        counter = counter + 1
    end
    return counter
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Loads the templates.
--
function TileFactory.loadTemplates()
    Log.info( 'Loading Tile Templates...', 'TileFactory' )
    templates.tiles = load( TEMPLATE_FILE )
    Log.info( string.format( 'Done! Loaded %d templates!', countTemplates( templates.tiles )), 'TileFactory' )
end

---
-- Creates a tile of a certain id at the given coordinates.
-- @tparam  string id The id of Tile to create.
-- @treturn Tile      The newly created Tile.
--
function TileFactory.create( id )
    local template = templates.tiles[id]
    assert( template, string.format( 'Requested tile id (%s) doesn\'t exist!', id ))
    return Tile( template.id, template.movementCost, template.passable, template.spawn )
end

---
-- Returns the table containing all the tile templates.
-- @treturn table A table containing all templates indexed by their id.
--
function TileFactory.getTemplates()
    return templates.tiles
end

return TileFactory
