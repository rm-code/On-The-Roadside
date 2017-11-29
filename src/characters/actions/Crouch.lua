---
-- This Action is used to change a character's stance to a crouch.
-- @module Crouch
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Action = require( 'src.characters.actions.Action' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Crouch = Action:subclass( 'Crouch' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local STANCES = require( 'src.constants.STANCES' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function Crouch:initialize( character )
    Action.initialize( self, character, character:getTile(), 1 )
end

function Crouch:perform()
    if self.character:getStance() == STANCES.CROUCH then
        return false
    end

    self.character:setStance( STANCES.CROUCH )
    return true
end

return Crouch
