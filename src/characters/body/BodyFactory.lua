local Body = require( 'src.characters.body.Body' );
local BodyPart = require( 'src.characters.body.BodyPart' );
local Equipment = require( 'src.characters.body.Equipment' );
local EquipmentSlot = require( 'src.characters.body.EquipmentSlot' );
local TGFParser = require( 'lib.TGFParser' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BodyFactory = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TEMPLATE_DIRECTORY_CREATURES  = 'res/data/creatures/';

-- ------------------------------------------------
-- Private Variables
-- ------------------------------------------------

local templates;    -- Define the attributes for each body part.
local layouts;      -- Define how body parts are connected.

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Returns a list of all files inside the specified directory.
-- @param dir (string) The directory to load the templates from.
-- @return    (table)  A sequence containing all files in the directory.
--
local function loadFiles( dir )
    local files = {};
    for i, file in ipairs( love.filesystem.getDirectoryItems( dir )) do
        local fn, fe = file:match( '^(.+)%.(.+)$' );
        files[i] = { name = fn, extension = fe };
        print( string.format( '%6d. %s.%s', i, fn, fe ));
    end
    return files;
end

---
-- Loads all templates for body parts found in the specified directory.
-- @param files (table) A sequence containing all files in the directory.
-- @return      (table) A table containing the body part templates.
--
local function loadTemplates( files )
    local tmp = {};
    for _, file in ipairs( files ) do
        if file.extension == 'lua' then
            local path = string.format( '%s%s.%s', TEMPLATE_DIRECTORY_CREATURES, file.name, file.extension );
            local status, loaded = pcall( love.filesystem.load, path );
            if not status then
                print( 'Can not load ' .. path );
            else
                local creature = loaded();
                tmp[creature.id] = {};
                -- Create template library for this creature.
                for _, sub in ipairs( creature ) do
                    tmp[creature.id][sub.id] = sub;
                end
            end
        end
    end
    return tmp;
end

---
-- Loads all creatures templates and converts them using the TGFParser.
-- @param files (table) A sequence containing all files in the directory.
-- @return      (table) A table containing the converted templates.
--
local function loadLayouts( files )
    local tmp = {};
    for _, file in ipairs( files ) do
        if file.extension == 'tgf' then
            local path = string.format( '%s%s.%s', TEMPLATE_DIRECTORY_CREATURES, file.name, file.extension );
            local status, template = pcall( TGFParser.parse, path );
            if not status then
                print( 'Can not load ' .. path );
            else
                tmp[file.name] = template;
            end
        end
    end
    return tmp;
end

---
-- Creates a body part based on the id returned from the creature's template. If
-- a body part is of the type 'equipment' it will be added to the creature's
-- equipment instead.
-- @param cid       (string)    The body id of the creature to create.
-- @param body      (Body)      The body to add this body part to.
-- @param equipment (Equipment) The equipment object to add a new slot to.
-- @param index     (number)    A unique number identifying a specific node in the graph.
-- @param id        (string)    The id used to determine the body part to create.
--
local function createBodyPart( cid, body, equipment, index, id )
    local template = templates[cid][id];
    if template.type == 'equipment' then
        equipment:addSlot( EquipmentSlot.new( index, template ));
    else
        body:addBodyPart( BodyPart.new( index, template ));
    end
end

---
-- Assembles a body from the different body parts and connections found in the
-- body template.
-- @param cid    (string) The body id of the creature to create.
-- @param layout (table)  A table containing the nodes and edges of the body graph.
-- @return       (Body)   A shiny new Body.
--
local function assembleBody( cid, layout )
    local body = Body.new();
    local equipment = Equipment.new();

    -- The index is the number used inside of the graph whereas the id determines
    -- which type of object to create for this node.
    for index, id in ipairs( layout.nodes ) do
        createBodyPart( cid, body, equipment, index, id );
    end

    -- Connect the bodyparts.
    for _, edge in ipairs( layout.edges ) do
        body:addConnection( edge );
    end

    -- Set the equipment to be used for this body.
    body:setEquipment( equipment );

    return body;
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Loads the templates.
--
function BodyFactory.loadTemplates()
    print( "Load Creature-Templates:" )
    local files = loadFiles( TEMPLATE_DIRECTORY_CREATURES );
    layouts = loadLayouts( files );
    templates = loadTemplates( files );
end

---
-- Creates a body based on the specified id.
-- @param id (string) The body id of the creature to create.
-- @return   (Body)   The newly created Body.
--
function BodyFactory.create( id )
    local template = layouts[id];
    assert( template, string.format( 'Requested body template (%s) doesn\'t exist!', id ));
    return assembleBody( id, template );
end

return BodyFactory;
