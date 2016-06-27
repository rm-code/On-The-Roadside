local Object = require('src.Object');

local Action = {};

function Action.new( cost, target )
    local self = Object.new():addInstance( 'Action' );

    function self:getCost()
        return cost;
    end

    function self:getTarget()
        return target;
    end

    return self;
end

return Action;
