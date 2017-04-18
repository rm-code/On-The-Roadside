local Action = require('src.characters.actions.Action');

local StandUp = {};

local STANCES = require( 'src.constants.STANCES' )

function StandUp.new( character )
    local self = Action.new( 1, character:getTile() ):addInstance( 'StandUp' );

    function self:perform()
        if character:getStance() == STANCES.STAND then
            return false;
        end

        character:setStance( STANCES.STAND );
        return true;
    end

    return self;
end

return StandUp;
