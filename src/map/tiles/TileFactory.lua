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
                print( 'Can not load ' .. dir .. file );
            else
                local template = loaded();
                local type = template.type;
                tiles[type] = template;
                print( string.format( '  %d. %s', i, template.name ));
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
    print( "Load Tile Templates:" )
    load( TEMPLATE_DIRECTORY );
end

---
-- Creates a tile of a certain type at the given coordinates.
-- @param x    (number) The tile's coordinate along the x-axis.
-- @param y    (number) The tile's coordinate along the y-axis.
-- @param type (string) The type of Tile to create.
-- @return     (Tile)   The newly created Tile.
--
function TileFactory.create( x, y, type )
    local template = tiles[type];
    assert( template, string.format( 'Requested tile type (%s) doesn\'t exist!', type ));
    return Tile.new( x, y, template );
end

return TileFactory;
