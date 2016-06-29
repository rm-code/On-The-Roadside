local Object = require('src.Object');

local CharacterNode = {};

function CharacterNode.new( character )
    local self = Object.new():addInstance( 'CharacterNode' );

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

    function self:getCharacter()
        return character;
    end

    return self;
end

return CharacterNode;
