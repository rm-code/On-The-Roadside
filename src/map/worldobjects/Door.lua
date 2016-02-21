local WorldObject = require( 'src.map.worldobjects.WorldObject' );

local Door = {};

function Door.new( passable )
    local self = WorldObject.new( passable ):addInstance( 'Door' );

    local open = false;

    function self:isOpen()
        return open;
    end

    function self:setOpen( nopen )
        open = nopen;
    end

    return self;
end

return Door;
