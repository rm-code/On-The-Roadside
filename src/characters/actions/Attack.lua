local Action = require('src.characters.actions.Action');

local Attack = {};

function Attack.new( character, target )
    local self = Action.new( 3 ):addInstance( 'Attack' );

    function self:perform()
        print( "Pow pow pow" );
    end

    return self;
end

return Attack;
