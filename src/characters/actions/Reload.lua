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
    for _, stack in pairs( inventory:getItems() ) do
        for _, item in pairs( stack:getItems() ) do
            reload( weapon, inventory, item )
            if weapon:getMagazine():isFull() then
                return true
            end
        end
    end

    return true
end

return Reload
