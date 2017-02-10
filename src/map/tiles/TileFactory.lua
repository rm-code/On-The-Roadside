local Log = require( 'src.util.Log' );
local Tile = require( 'src.map.tiles.Tile' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local TileFactory = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TEMPLATE_DIRECTORY  = 'res/data/tiles/';

-- ------------------------------------------------
-- Private Variables
-- ------------------------------------------------

local tiles = {};

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Loads all Tile-templates found in the specified directory.
-- @param dir (string) The directory to load the templates from.
--
local function load( dir )
    local files = love.filesystem.getDirectoryItems( dir );
    for i, file in ipairs( files ) do
        if love.filesystem.isFile( dir .. file ) then
            local status, loaded = pcall( love.filesystem.load, dir .. file );
            if not status then
                Log.warn( 'Can not load ' .. dir .. file );
            else
                local template = loaded();
                local id = template.id;
                tiles[id] = template;
                Log.debug( string.format( '  %d. %s', i, template.id ));
            end
        end
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
    load( TEMPLATE_DIRECTORY );
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
