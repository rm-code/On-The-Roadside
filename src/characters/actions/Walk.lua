local Action = require('src.characters.actions.Action');
local Messenger = require( 'src.Messenger' );

local Walk = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local STANCES = require('src.constants.Stances');
local STANCE_MODIFIER = {
    [STANCES.STAND]  = 1.0,
    [STANCES.CROUCH] = 1.5,
    [STANCES.PRONE]  = 2.0,
}

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function Walk.new( character, target )
    local self = Action.new( math.floor( target:getMovementCost() * STANCE_MODIFIER[character:getStance()] ), target ):addInstance( 'Walk' );

    function self:perform()
        local current = character:getTile();

        assert( target:isPassable(), 'Target tile has to be passable!' );
        assert( not target:isOccupied(), 'Target tile must not be occupied by another character!' );
        assert( target:isAdjacent( current ), 'Character has to be adjacent to the target tile!' );

        Messenger.publish( 'CHARACTER_MOVED', character );

        -- Remove the character from the old tile, add it to the new one and
        -- give it a reference to the new tile.
        current:removeCharacter();
        target:addCharacter( character );
        character:setTile( target );
        return true;
    end

    return self;
end

return Walk;
