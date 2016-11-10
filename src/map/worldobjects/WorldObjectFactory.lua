local WorldObject = require( 'src.map.worldobjects.WorldObject' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local WorldObjectFactory = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TEMPLATE_DIRECTORY  = 'res/data/worldobjects/';

-- ------------------------------------------------
-- Private Variables
-- ------------------------------------------------

local worldobjects = {};

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Loads all WorldObject templates found in the specified directory.
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
                local id = template.id;
                worldobjects[id] = template;
                print( string.format( '  %d. %s', i, template.id ));
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
function WorldObjectFactory.loadTemplates()
    print( "Load WorldObject Templates:" )
    load( TEMPLATE_DIRECTORY );
end

---
-- Creates a WorldObject of the given id.
-- @param id   (string)      The id of the WorldObject to create.
-- @return     (WorldObject) The newly created WorldObject.
--
function WorldObjectFactory.create( id )
    local template = worldobjects[id];
    assert( template, string.format( 'Requested worldobject id (%s) doesn\'t exist!', id ));
    return WorldObject.new( template );
end

return WorldObjectFactory;
