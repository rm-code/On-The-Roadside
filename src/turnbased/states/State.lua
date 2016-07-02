local State = {};

function State.new()
    local self = {};

    function self:enter() end
    function self:keypressed() end
    function self:leave() end
    function self:selectTile() end
    function self:processEvent() end
    function self:update() end

    return self;
end

return State;
