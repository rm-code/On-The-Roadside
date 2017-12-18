---
-- The WorldObjectFactory takes care of loading templates for and creating
-- world objects such as doors, trees and basically any object that can be
-- placed on a tile.
-- @module WorldObjectFactory
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )
local WorldObject = require( 'src.map.worldobjects.WorldObject' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local WorldObjectFactory = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TEMPLATE_FILE  = 'res.data.WorldObjects'

-- ------------------------------------------------
-- Private Variables
-- ------------------------------------------------

local worldobjects = {}

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Loads all WorldObject-templates found in the specified file.
-- @tparam string src The file to load the templates from.
--
local function load( src )
    local module = require( src )
    local counter = 0

    for _, template in ipairs( module ) do
        worldobjects[template.id] = template
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
function WorldObjectFactory.loadTemplates()
    Log.debug( "Load WorldObject Templates:" )
    load( TEMPLATE_FILE )
end

---
-- Creates a WorldObject of the given id.
-- @tparam  string  id  The id of the WorldObject to create.
-- @treturn WorldObject The newly created WorldObject.
--
function WorldObjectFactory.create( id )
    local template = worldobjects[id]
    assert( template, string.format( 'Requested worldobject id (%s) doesn\'t exist!', id ))
    return WorldObject( template )
end

---
-- Returns the table containing all the worldobject templates.
-- @treturn table A table containing all templates indexed by their id.
--
function WorldObjectFactory.getTemplates()
    return worldobjects
end

return WorldObjectFactory
