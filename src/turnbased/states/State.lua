local Object = require('src.Object');

local State = {};

function State.new()
    local self = Object.new():addInstance( 'State' );

    function self:enter() end
    function self:update() end
    function self:leave() end

    return self;
end

return State;
