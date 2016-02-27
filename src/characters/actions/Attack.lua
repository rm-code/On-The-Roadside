local Action = require('src.characters.actions.Action');

local Attack = {};

function Attack.new( character )
    local self = Action.new( 5 ):addInstance( 'Attack' );

    function self:perform()
        character:getLineOfSight():iterate( function( tile )
            if tile ~= character:getTile() and ( not tile:isPassable() or tile:isOccupied() ) then
                tile:hit();
                return true;
            end
        end)
    end

    return self;
end

return Attack;
