---
-- The Walk Action takes care of moving a Character from one tile to another.
-- @module Walk
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Action = require( 'src.characters.actions.Action' )
local Messenger = require( 'src.Messenger' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Walk = Action:subclass( 'Walk' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function Walk:initialize( character, target )
    Action.initialize( self, character, target, target:getMovementCost( character:getStance() ))
end

function Walk:perform()
    local current = self.character:getTile()

    assert( self.target:isPassable(), 'Target tile has to be passable!' )
    assert( not self.target:isOccupied(), 'Target tile must not be occupied by another character!' )
    assert( self.target:isAdjacent( current ), 'Character has to be adjacent to the target tile!' )

    Messenger.publish( 'CHARACTER_MOVED', self.character )

    -- Remove the character from the old tile, add it to the new one and
    -- give it a reference to the new tile.
    current:removeCharacter()
    self.target:setCharacter( self.character )
    self.character:setTile( self.target )
    return true
end

return Walk
