local Action = require('src.characters.actions.Action');

local Crouch = {};

local STANCES = require('src.constants.Stances');

function Crouch.new( character )
    local self = Action.new( 1, character:getTile() ):addInstance( 'Crouch' );

    function self:perform()
        character:setStance( STANCES.CROUCH );
    end

    return self;
end

return Crouch;
