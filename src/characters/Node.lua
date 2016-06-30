local Object = require('src.Object');

local Node = {};

function Node.new( object )
    local self = Object.new():addInstance( 'Node' );

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

    function self:getObject()
        return object;
    end

    return self;
end

return Node;
