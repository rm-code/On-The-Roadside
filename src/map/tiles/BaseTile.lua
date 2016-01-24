local Object = require( 'src.Object' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BaseTile = {};

function BaseTile.new( type, x, y )
    local self = Object.new():addInstance( 'BaseTile' );

    self:validateType( 'string', type );
    self:validateType( 'number', x );
    self:validateType( 'number', y );

    local neighbours;

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

    function self:getType()
        return type;
    end

    return self;
end

return BaseTile;
