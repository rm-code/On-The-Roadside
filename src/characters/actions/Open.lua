---
-- This Action is used when a character opens an openable world object.
-- @module Open
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Action = require( 'src.characters.actions.Action' )
local SoundManager = require( 'src.SoundManager' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Open = Action:subclass( 'Close' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function Open:initialize( character, target )
    Action.initialize( self, character, target, target:getWorldObject():getInteractionCost( character:getStance() ))
end

function Open:perform()
    local targetObject = self.target:getWorldObject()
    assert( targetObject:isOpenable(), 'Target needs to be openable!' )
    assert( not targetObject:isPassable(), 'Target tile needs to be impassable!' )
    assert( self.target:isAdjacent( self.character:getTile() ), 'Character has to be adjacent to the target tile!' )

    SoundManager.play( 'sound_door' )

    -- Update the WorldObject.
    targetObject:setPassable( true )
    targetObject:setBlocksVision( false )

    -- Mark target tile for update.
    self.target:setDirty( true )
    return true
end

return Open
