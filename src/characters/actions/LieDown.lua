---
-- This Action is used to change the character to a prone stance.
-- @module LieDown
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Action = require( 'src.characters.actions.Action' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local LieDown = Action:subclass( 'LieDown' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local STANCES = require( 'src.constants.STANCES' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function LieDown:initialize( character )
    Action.initialize( self, character, character:getTile(), 1 )
end

function LieDown:perform()
    if self.character:getStance() == STANCES.PRONE then
        return false
    end

    self.character:setStance( STANCES.PRONE )
    return true
end

return LieDown
