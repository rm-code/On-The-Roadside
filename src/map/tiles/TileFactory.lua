local Tile = require( 'src.map.tiles.Tile' );

local TEMPLATE_DIRECTORY  = 'res/data/tiles/';

local TileFactory = {};

local tiles = {};

local function load( dir )
    local files = love.filesystem.getDirectoryItems( dir );
    for i, file in ipairs( files ) do
        if love.filesystem.isFile( dir .. file ) then
            local template = love.filesystem.load( dir .. file )();
            local type = template.type;

            tiles[type] = template;

            print( string.format( '  %d. %s', i, template.name ));
        end
    end
end

function TileFactory.loadTemplates()
    print( "Load Tile Templates:" )
    load( TEMPLATE_DIRECTORY );
end

function TileFactory.create( x, y, type )
    local template = tiles[type];
    assert( template, string.format( 'Requested tile type (%s) doesn\'t exist!', type ));
    return Tile.new( x, y, template.type, template.movementCost );
end

return TileFactory;
