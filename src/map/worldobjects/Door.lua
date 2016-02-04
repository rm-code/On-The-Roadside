local Object = require( 'src.Object' );

local Door = {};

function Door.new()
    local self = Object.new():addInstance( 'Door' );

    local open = false;

    function self:open()
        open = true;
    end

    function self:close()
        open = false;
    end

    function self:isOpen()
        return open;
    end

    function self:isPassable()
        return open;
    end

    function self:getType()
        return 'Door';
    end

    return self;
end

return Door;
