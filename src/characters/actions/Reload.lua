---
-- This Action tries to reload the currently equipped weapon.
-- @module Reload
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Action = require( 'src.characters.actions.Action' )
local Log = require( 'src.util.Log' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Reload = Action:subclass( 'Reload' )

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

    if weapon:isFull() then
        Log.debug( 'Weapon is fully loaded.' )
        return false
    end

    weapon:reload()

    return true
end

return Reload
