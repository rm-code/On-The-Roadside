local Object = require('src.Object');

local Action = {};

function Action.new( cost )
    local self = Object.new():addInstance( 'Action' );

    function self:getCost()
        return cost;
    end

    return self;
end

return Action;
