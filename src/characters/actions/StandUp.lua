local Action = require('src.characters.actions.Action');

local StandUp = {};

local STANCES = require('src.constants.Stances');

function StandUp.new( character )
    local self = Action.new( 1, character:getTile() ):addInstance( 'StandUp' );

    function self:perform()
        character:setStance( STANCES.STAND );
    end

    return self;
end

return StandUp;
