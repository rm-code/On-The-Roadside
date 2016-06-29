local Object = require('src.Object');
local CharacterNode = require('src.characters.CharacterNode');

local Faction = {};

function Faction.new( type )
    local self = Object.new():addInstance( 'Faction' );

    local root;
    local active;
    local last;

    function self:addCharacter( nchar )
        local node = CharacterNode.new( nchar );

        -- Initialise root node.
        if not root then
            root = node;
            active = root;
            last = active;
            return;
        end

        -- Doubly link the new node.
        active:linkNext( node );
        node:linkPrev( active );

        -- Make the new node active and mark it as the last node in our list.
        active = node;
        last = active;
    end

    function self:findCharacter( character )
        assert( character:instanceOf( 'Character' ), 'Expected object of type Character!' );
        local node = root;
        while node do
            if node:getCharacter() == character and not node:getCharacter():isDead() then
                active = node;
                break;
            end
            node = node:getNext();
        end
    end

    function self:iterate( callback )
        local node = root;
        while node do
            callback( node:getCharacter() );
            node = node:getNext();
        end
    end

    function self:getCurrentCharacter()
        return active:getCharacter();
    end

    function self:nextCharacter()
        while active do
            active = active:getNext() or root;
            if not active:getCharacter():isDead() then
                return active:getCharacter();
            end
        end
    end

    function self:prevCharacter()
        while active do
            active = active:getPrev() or last;
            if not active:getCharacter():isDead() then
                return active:getCharacter();
            end
        end
    end

    function self:hasLivingCharacters()
        local node = root;
        while node do
            if not node:getCharacter():isDead() then
                return true;
            end
            node = node:getNext();
        end
        return false;
    end

    function self:getType()
        return type;
    end

    return self;
end

return Faction;
