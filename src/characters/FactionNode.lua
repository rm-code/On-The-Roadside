local Object = require('src.Object');

local FactionNode = {};

function FactionNode.new( faction )
    local self = Object.new():addInstance( 'FactionNode' );

    local next;
    local prev;

    function self:linkNext( node )
        next = node;
    end

    function self:linkPrev( node )
        prev = node;
    end

    function self:getNext()
        return next;
    end

    function self:getPrev()
        return prev;
    end

    function self:getFaction()
        return faction;
    end

    return self;
end

return FactionNode;
