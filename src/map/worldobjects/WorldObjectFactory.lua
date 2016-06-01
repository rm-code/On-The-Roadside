local WorldObject = require( 'src.map.worldobjects.WorldObject' );

local TEMPLATE_DIRECTORY  = 'res/data/worldobjects/';

local WorldObjectFactory = {};

local worldobjects = {};

local function load( dir )
    local files = love.filesystem.getDirectoryItems( dir );
    for i, file in ipairs( files ) do
        if love.filesystem.isFile( dir .. file ) then
            local template = love.filesystem.load( dir .. file )();
            local type = template.type;

            worldobjects[type] = template;

            print( string.format( '  %d. %s', i, template.name ));
        end
    end
end

function WorldObjectFactory.loadTemplates()
    print( "Load Tile Templates:" )
    load( TEMPLATE_DIRECTORY );
end

function WorldObjectFactory.create( type )
    local template = worldobjects[type];
    assert( template, string.format( 'Requested worldobject type (%s) doesn\'t exist!', type ));
    return WorldObject.new( template.type, template.passable, template.blocksPathfinding, template.destructible );
end

return WorldObjectFactory;
