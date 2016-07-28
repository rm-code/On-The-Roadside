local Action = require('src.characters.actions.Action');

local LieDown = {};

local STANCES = require('src.constants.Stances');

function LieDown.new( character )
    local self = Action.new( 1, character:getTile() ):addInstance( 'LieDown' );

    function self:perform()
        character:setStance( STANCES.PRONE );
    end

    return self;
end

return LieDown;
