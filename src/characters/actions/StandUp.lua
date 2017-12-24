---
-- This Action is used to change the character to a standing stance.
-- @module StandUp
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Action = require( 'src.characters.actions.Action' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local StandUp = Action:subclass( 'StandUp' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local STANCES = require( 'src.constants.STANCES' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function StandUp:initialize( character )
    Action.initialize( self, character, character:getTile(), 1 )
end

function StandUp:perform()
    if self.character:getStance() == STANCES.STAND then
        return false
    end

    self.character:setStance( STANCES.STAND );
    return true
end

return StandUp
