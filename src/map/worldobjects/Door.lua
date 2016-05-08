local WorldObject = require( 'src.map.worldobjects.WorldObject' );

local Door = {};

function Door.new()
    local self = WorldObject.new( false ):addInstance( 'Door' );

    function self:getMovementCost()
        if self:isPassable() then
            return 1;
        end
        return 3;
    end

    return self;
end

return Door;
