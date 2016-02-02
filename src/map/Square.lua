local Object = require( 'src.Object' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Square = {};

function Square.new( x, y, worldObject )
    local self = Object.new():addInstance( 'Square' );

    self:validateType( 'number', x );
    self:validateType( 'number', y );

    local neighbours;
    local character;    -- Each tiles can hold one game character.

    function self:removeCharacter()
        character = nil;
    end

    function self:setNeighbours( nneighbours )
        neighbours = nneighbours;
    end

    function self:getNeighbours()
        return neighbours;
    end

    function self:getPosition()
        return x, y;
    end

    function self:getX()
        return x;
    end

    function self:getY()
        return y;
    end

    function self:getWorldObject()
        return worldObject;
    end

    function self:getCharacter()
        return character;
    end

    function self:isOccupied()
        return character ~= nil;
    end

    function self:setCharacter( nchar )
        character = nchar;
    end

    return self;
end

return Square;
