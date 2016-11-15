local Body = require( 'src.characters.body.Body' );
local BodyPart = require( 'src.characters.body.BodyPart' );
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
-- Assembles a body from the different body parts and connections found in the
-- body template.
-- @param  bodyTemplate (table) A table containing the nodes and edges of the body graph.
-- @return              (Body)  A shiny new Body.
--
local function assembleBody( bodyTemplate )
    local body = Body.new();

    -- Add body parts.
    for index, type in ipairs( bodyTemplate.nodes ) do
        assert( bodyParts[type], string.format( "Can't find template for body part '%s'", type ));
        local template = bodyParts[type];
        local part = BodyPart.new( index, template );
        body:addBodyPart( part );
    end

    -- Connect the bodyparts.
    for _, edge in ipairs( bodyTemplate.edges ) do
        edge.name = tonumber( edge.name );
        body:addConnection( edge );
    end

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
