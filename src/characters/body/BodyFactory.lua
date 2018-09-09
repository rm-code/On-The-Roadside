---
-- The BodyFactory is used to assemble the bodies of each creature in the game
-- from their template files.
--
-- @module BodyFactory
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )
local Body = require( 'src.characters.body.Body' )
local Equipment = require( 'src.characters.body.Equipment' )
local Inventory = require( 'src.inventory.Inventory' )
local EquipmentSlot = require( 'src.characters.body.EquipmentSlot' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BodyFactory = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TEMPLATE_DIRECTORY_CREATURES  = 'res/data/creatures/bodies/'
local TEMPLATE_EXTENSION = 'lua'

-- ------------------------------------------------
-- Private Variables
-- ------------------------------------------------

local templates -- Define the attributes for each body part.

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Returns a list of all files inside the specified directory.
-- @tparam  string dir The directory to load the templates from.
-- @treturn table A sequence containing all files in the directory.
--
local function loadFiles( dir )
    local files = {}
    for i, file in ipairs( love.filesystem.getDirectoryItems( dir )) do
        local fn, fe = file:match( '^(.+)%.(.+)$' )
        if fe == TEMPLATE_EXTENSION then
            local template = require( dir .. fn )
            files[template.id] = template
            Log.debug( string.format( '%3d. %s.%s', i, fn, fe ))
        end
    end
    return files
end

---
-- Creates the creature's equipment.
-- @tparam Inventory inventory The inventory to observe.
-- @tparam table template The template to use for the equipment.
--
local function createEquipment( inventory, template )
    local equipment = Equipment()

    -- Create the different equipment slots.
    for index, slot in ipairs( template.equipment ) do
        equipment:addSlot( EquipmentSlot( index, slot.id, slot.itemType, slot.subType, slot.sort ))
    end

    -- Observe the inventory.
    equipment:observe( inventory )
    return equipment
end

---
-- Assembles a new body.
-- @tparam table template A table containing the definitions for this creature's body parts.
-- @tparam table stats A table containing the stats for this creature defined by its class.
-- @treturn Body A shiny new Body.
--
local function assembleBody( template, stats )
    local inventory = Inventory( template.defaultCarryWeight, template.defaultCarryVolume )
    local equipment = createEquipment( inventory, template )

    return Body( template.id, stats.hp, template.tags, template.size, template.bodyparts, equipment, inventory )
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Loads the templates.
--
function BodyFactory.loadTemplates()
    Log.debug( "Load Creature-Templates:" )
    templates = loadFiles( TEMPLATE_DIRECTORY_CREATURES )
end

---
-- Creates a body based on the specified id.
-- @tparam string id The body id of the creature to create.
-- @treturn Body The newly created Body.
--
function BodyFactory.create( id, stats )
    local template = templates[id]
    assert( template, string.format( 'Requested body template (%s) doesn\'t exist!', id ))
    return assembleBody( template, stats )
end

---
-- Loads a body based on a saved file.
-- @tparam table savedBody A table containing the saved body.
-- @treturn Body The loaded body.
--
function BodyFactory.load( savedbody )
    local template = templates[savedbody.id]

    local inventory = Inventory( template.defaultCarryWeight, template.defaultCarryVolume )
    local equipment = createEquipment( inventory, template )
    local body = Body( template.id, savedbody.maximumHP, template.tags, template.size, template.bodyparts, equipment, inventory )
    body:setCurrentHP( savedbody.currentHP )

    for effect, _ in pairs( savedbody.statusEffects ) do
        body:getStatusEffects():add({ effect })
    end

    body:getInventory():loadItems( savedbody.inventory )
    body:getEquipment():load( savedbody.equipment )

    return body
end

return BodyFactory
