---
-- @module BTCanReload
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )
local BTLeaf = require( 'src.characters.ai.behaviortree.leafs.BTLeaf' )
local Magazine = require( 'src.items.weapons.Magazine' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BTCanReload = BTLeaf:subclass( 'BTCanReload' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function BTCanReload:traverse( ... )
    local _, character = ...

    local weapon = character:getWeapon()
    local inventory = character:getInventory()
    for _, item in pairs( inventory:getItems() ) do
        if item:isInstanceOf( Magazine ) and item:getCaliber() == weapon:getCaliber() then
            Log.debug( 'Character can reload', 'BTCanReload' )
            return true
        end
    end

    Log.debug( 'Character can not reload', 'BTCanReload' )
    return false
end

return BTCanReload
