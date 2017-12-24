---
-- This Action tries to reload the currently equipped weapon.
-- @module Reload
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Action = require( 'src.characters.actions.Action' )
local Log = require( 'src.util.Log' )
local Ammunition = require( 'src.items.weapons.Ammunition' )
local Item = require( 'src.items.Item' )
local ItemStack = require( 'src.inventory.ItemStack' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Reload = Action:subclass( 'Reload' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

local function reload( weapon, inventory, item )
    if item:isInstanceOf( Ammunition ) and item:getCaliber() == weapon:getMagazine():getCaliber() then
        weapon:getMagazine():addRound( item )
        inventory:removeItem( item )
    end
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function Reload:initialize( character )
    Action.initialize( self, character, character:getTile(), 5 )
end

function Reload:perform()
    local weapon = self.character:getWeapon()

    if not weapon or not weapon:isReloadable() then
        Log.debug( 'Can not reload.' )
        return false
    end

    if weapon:getMagazine():isFull() then
        Log.debug( 'Weapon is fully loaded.' )
        return false
    end

    local inventory = self.character:getInventory()
    for _, item in pairs( inventory:getItems() ) do
        if item:isInstanceOf( ItemStack ) then
            for _, sitem in pairs( item:getItems() ) do
                reload( weapon, inventory, sitem )
                if weapon:getMagazine():isFull() then
                    return true
                end
            end
        elseif item:isInstanceOf( Item ) then
            reload( weapon, inventory, item )
            if weapon:getMagazine():isFull() then
                return true
            end
        end
    end

    return true
end

return Reload
