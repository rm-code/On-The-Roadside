local Action = require('src.characters.actions.Action');

local LieDown = {};

local STANCES = require( 'src.constants.STANCES' )

function LieDown.new( character )
    local self = Action.new( 1, character:getTile() ):addInstance( 'LieDown' );

    function self:perform()
        if character:getStance() == STANCES.PRONE then
            return false;
        end

        character:setStance( STANCES.PRONE );
        return true;
    end

    return self;
end

return LieDown;
