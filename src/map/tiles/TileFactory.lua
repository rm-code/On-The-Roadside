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

local tiles = {}

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Loads all Tile-templates found in the specified file.
-- @tparam string src The file to load the templates from.
--
local function load( src )
    local module = require( src )
    local counter = 0

    for _, template in ipairs( module ) do
        tiles[template.id] = template
        counter = counter + 1
        Log.debug( string.format( '  %3d. %s', counter, template.id ))
    end
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Loads the templates.
--
function TileFactory.loadTemplates()
    Log.debug( "Load Tile Templates:" )
    load( TEMPLATE_FILE )
end

---
-- Creates a tile of a certain id at the given coordinates.
-- @tparam  string id The id of Tile to create.
-- @treturn Tile      The newly created Tile.
--
function TileFactory.create( id )
    local template = tiles[id]
    assert( template, string.format( 'Requested tile id (%s) doesn\'t exist!', id ))
    return Tile( template.id, template.movementCost, template.passable, template.spawn )
end

---
-- Returns the table containing all the tile templates.
-- @treturn table A table containing all templates indexed by their id.
--
function TileFactory.getTemplates()
    return tiles
end

return TileFactory
