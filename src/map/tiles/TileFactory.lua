local Log = require( 'src.util.Log' );
local Tile = require( 'src.map.tiles.Tile' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local TileFactory = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TEMPLATE_FILE  = 'res.data.Tiles'

-- ------------------------------------------------
-- Private Variables
-- ------------------------------------------------

local tiles = {};

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
-- @param x    (number) The tile's coordinate along the x-axis.
-- @param y    (number) The tile's coordinate along the y-axis.
-- @param id   (string) The id of Tile to create.
-- @return     (Tile)   The newly created Tile.
--
function TileFactory.create( x, y, id )
    local template = tiles[id];
    assert( template, string.format( 'Requested tile id (%s) doesn\'t exist!', id ));
    return Tile.new( x, y, template );
end

return TileFactory;
