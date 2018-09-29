---
-- @module OpenInventory
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Action = require( 'src.characters.actions.Action' )
local ScreenManager = require( 'lib.screenmanager.ScreenManager' )

-- ------------------------------------------------
-- Required Module
-- ------------------------------------------------

local OpenInventory = Action:subclass( 'OpenInventory' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local WORLDOBJECT_INVENTORY = 'inventory_container_inventory'
local CHARACTER_INVENTORY = 'inventory_character'
local TILE_INVENTORY = 'inventory_tile_inventory'

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

local function findTarget( character, target )
    local id, inventory
    if target:hasWorldObject() and target:getWorldObject():isContainer() then
        id, inventory = WORLDOBJECT_INVENTORY, target:getWorldObject():getInventory()
    elseif target:hasCharacter() and target:getCharacter() ~= character and target:getCharacter():getFaction():getType() == character:getFaction():getType() then
        id, inventory = CHARACTER_INVENTORY, target:getCharacter():getInventory()
    else
        id, inventory = TILE_INVENTORY, target:getInventory()
    end
    return id, inventory
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function OpenInventory:initialize( character, target )
    Action.initialize( self, character, target, 0 )
end

function OpenInventory:perform()
    local targetID, targetInventory = findTarget( self.character, self.target )
    ScreenManager.push( 'inventory', self.character, targetID, targetInventory, self.target:getInventory() )
    return true
end

return OpenInventory
