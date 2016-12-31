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

local TEMPLATE_DIRECTORY_BODY_PARTS = 'res/data/creatures/bodyparts/';
local TEMPLATE_DIRECTORY_CREATURES  = 'res/data/creatures/';

-- ------------------------------------------------
-- Private Variables
-- ------------------------------------------------

local bodyParts;
local creatures;

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Loads all templates for body parts found in the specified directory.
-- @param dir (string) The directory to load the templates from.
-- @return    (table)  A table containing the body part templates.
--
local function loadBodyParts( dir )
    local files = love.filesystem.getDirectoryItems( dir );
    local templates = {};
    for i, file in ipairs( files ) do
        if love.filesystem.isFile( dir .. file ) then
            local status, loaded = pcall( love.filesystem.load, dir .. file );
            if not status then
                print( 'Can not load ' .. dir .. file );
            else
                local template = loaded();
                local id = template.id;
                templates[id] = template;
                print( string.format( '  %d. %s', i, template.id ));
            end
        end
    end
    return templates;
end

---
-- Loads all creatures templates and converts them using the TGFParser.
-- @param dir (string) The directory to load the templates from.
-- @return    (table)  A table containing the converted templates.
--
local function loadTGFTemplates( dir )
    local files = love.filesystem.getDirectoryItems( dir );
    local templates = {};
    for i, file in ipairs( files ) do
        if love.filesystem.isFile( dir .. file ) then
            local status, template = pcall( TGFParser.parse, dir .. file );
            if not status then
                print( 'Can not load ' .. dir .. file );
            else
                -- Remove file extension and use filename as id.
                template.id = file:match( '(.+)%.' );
                templates[template.id] = template;
                print( string.format( '  %d. %s', i, template.id ));
            end
        end
    end
    return templates;
end

---
-- Creates a body part based on the id returned from the creature's template. If
-- a body part is of the type 'equipment' it will be added to the creature's
-- equipment instead.
-- @param body      (Body)      The body to add this body part to.
-- @param equipment (Equipment) The equipment object to add a new slot to.
-- @param index     (number)    A unique number identifying a specific node in the graph.
-- @param id        (string)    The id used to determine the body part to create.
--
local function createBodyPart( body, equipment, index, id )
    local template = bodyParts[id];
    if template.type == 'equipment' then
        equipment:addSlot( EquipmentSlot.new( index, template ));
    else
        body:addBodyPart( BodyPart.new( index, template ));
    end
end

---
-- Assembles a body from the different body parts and connections found in the
-- body template.
-- @param  bodyTemplate (table) A table containing the nodes and edges of the body graph.
-- @return              (Body)  A shiny new Body.
--
local function assembleBody( bodyTemplate )
    local body = Body.new();
    local equipment = Equipment.new();

    -- The index is the number used inside of the graph whereas the id determines
    -- which type of object to create for this node.
    for index, id in ipairs( bodyTemplate.nodes ) do
        createBodyPart( body, equipment, index, id );
    end

    -- Connect the bodyparts.
    for _, edge in ipairs( bodyTemplate.edges ) do
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
    print( "Load Body Parts:" )
    bodyParts = loadBodyParts( TEMPLATE_DIRECTORY_BODY_PARTS );

    print( "Load Creatures:" )
    creatures = loadTGFTemplates( TEMPLATE_DIRECTORY_CREATURES );
end

---
-- Creates a body based on the specified id.
-- @param id (string) The body id of the creature to create.
-- @return   (Body)   The newly created Body.
--
function BodyFactory.create( id )
    local template = creatures[id];
    assert( template, string.format( 'Requested body template (%s) doesn\'t exist!', id ));
    return assembleBody( template );
end

return BodyFactory;
