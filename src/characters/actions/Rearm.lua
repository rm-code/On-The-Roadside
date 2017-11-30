---
-- This Action tries to re-equip the same weapon type the character had
-- previously equipped.
-- @module Rearm
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Action = require( 'src.characters.actions.Action' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Rearm = Action:subclass( 'Rearm' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Searches through the character's inventory and returns an item that fits
-- the searched weaponID.
-- @tparam  Inventory inventory The inventory to search through.
-- @tparam  string    weaponID  The item id to search for.
-- @treturn Item                The item matching the searched id (or nil).
--
local function findItem( inventory, weaponID )
    for _, item in pairs( inventory:getItems() ) do
        if item:instanceOf( 'Weapon' ) and item:getID() == weaponID then
            return item
        elseif item:instanceOf( 'ItemStack' ) then
            for _, sitem in pairs( item:getItems() ) do
                if sitem:instanceOf( 'Weapon' ) and sitem:getID() == weaponID then
                    return sitem
                end
            end
        end
    end
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function Rearm:initialize( character, weaponID )
    Action.initialize( self, character, character:getTile(), 0 )

    self.weaponID = weaponID
end

function Rearm:perform()
    local weapon = findItem( self.character:getInventory(), self.weaponID )

    -- Quit early if we haven't found a valid weapon.
    if not weapon then
        return false
    end

    -- Remove item from backpack and add it to the equipment slot.
    local equipment = self.character:getEquipment()
    for _, slot in pairs( equipment:getSlots() ) do
        if weapon:isSameType( slot:getItemType(), slot:getSubType() ) then
            equipment:addItem( slot, weapon )
            self.character:getInventory():removeItem( weapon )
            return true
        end
    end

    return false
end

return Rearm
