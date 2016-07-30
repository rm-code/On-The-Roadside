local Action = require('src.characters.actions.Action');

local Crouch = {};

local STANCES = require('src.constants.Stances');

function Crouch.new( character )
    local self = Action.new( 1, character:getTile() ):addInstance( 'Crouch' );

    function self:perform()
        if character:getStance() == STANCES.CROUCH then
            return false;
        end

        character:setStance( STANCES.CROUCH );
        return true;
    end

    return self;
end

return Crouch;
