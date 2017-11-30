local Log = require( 'src.util.Log' );
local Body = require( 'src.characters.body.Body' );
local BodyPart = require( 'src.characters.body.BodyPart' );
local Equipment = require( 'src.characters.body.Equipment' );
local Inventory = require( 'src.inventory.Inventory' );
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
local TEMPLATE_EXTENSION = 'lua';
local LAYOUT_EXTENSION = 'tgf';

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
        if fe == TEMPLATE_EXTENSION or fe == LAYOUT_EXTENSION then
            files[#files + 1] = { name = fn, extension = fe };
            Log.debug( string.format( '%3d. %s.%s', i, fn, fe ));
        end
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
        if file.extension == TEMPLATE_EXTENSION then
            local path = string.format( '%s%s.%s', TEMPLATE_DIRECTORY_CREATURES, file.name, file.extension );
            local status, loaded = pcall( love.filesystem.load, path );
            if not status then
                Log.warn( 'Can not load ' .. path );
            else
                local creature = loaded();
                tmp[creature.id] = {};

                -- Create template library for this creature.
                for id, sub in pairs( creature ) do
                    local i = type( sub ) == 'table' and sub.id or id;
                    tmp[creature.id][i] = sub;
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
        if file.extension == LAYOUT_EXTENSION then
            local path = string.format( '%s%s.%s', TEMPLATE_DIRECTORY_CREATURES, file.name, file.extension );
            local status, template = pcall( TGFParser.parse, path );
            if not status then
                Log.warn( 'Can not load ' .. path );
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
        body:addBodyPart( BodyPart( index, template.id, template.type, template.health, template.effects ))
    end
end

---
-- Assembles a body from the different body parts and connections found in the
-- body template.
-- @tparam  string creatureID The body id of the creature to create.
-- @tparam  table  template   A table containing the definitions for this creature's body parts.
-- @tparam  table  layout     A table containing the nodes and edges of the body layout's graph.
-- @treturn Body              A shiny new Body.
--
local function assembleBody( creatureID, template, layout )
    local body = Body( template.id, template.bloodVolume, template.tags, template.size )
    local equipment = Equipment.new();
    local inventory = Inventory.new( template.defaultCarryWeight, template.defaultCarryVolume )

    equipment:observe( inventory );

    -- The index is the number used inside of the graph whereas the id determines
    -- which type of object to create for this node.
    for index, id in ipairs( layout.nodes ) do
        createBodyPart( creatureID, body, equipment, index, id )
    end

    -- Connect the bodyparts.
    for _, edge in ipairs( layout.edges ) do
        body:addConnection( edge );
    end

    -- Set the equipment to be used for this body.
    body:setEquipment( equipment );
    body:setInventory( inventory );

    return body;
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Loads the templates.
--
function BodyFactory.loadTemplates()
    Log.debug( "Load Creature-Templates:" )
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
    local layout, template = layouts[id], templates[id]

    assert( layout, string.format( 'Requested body layout (%s) doesn\'t exist!', id ))
    assert( template, string.format( 'Requested body template (%s) doesn\'t exist!', id ))

    return assembleBody( id, template, layout )
end

function BodyFactory.load( savedbody )
    local body = BodyFactory.create( savedbody.id );

    for id, savedBodyPart in pairs( savedbody.nodes ) do
        body:getBodyPart( id ):load( savedBodyPart );
    end

    body:getInventory():loadItems( savedbody.inventory );
    body:getEquipment():load( savedbody.equipment );

    for effect, _ in pairs( savedbody.statusEffects ) do
        body:getStatusEffects():add({ effect });
    end

    return body;
end

return BodyFactory;
