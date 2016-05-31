local Object = require( 'src.Object' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Tile = {};

function Tile.new( x, y, type, movementCost )
    local self = Object.new():addInstance( 'Tile' );

    local id;
    local dirty;
    local neighbours;
    local character;    -- Each tiles can hold one game character.
    local worldObject;
    local visible;
    local explored;

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:addCharacter( nchar )
        character = nchar;
        self:setDirty( true );
    end

    function self:addNeighbours( nneighbours )
        neighbours = nneighbours;
    end

    function self:addWorldObject( nworldObject )
        worldObject = nworldObject;
    end

    function self:hit( damage )
        if self:isOccupied() then
            character:hit( damage );
        elseif self:hasWorldObject() and self:getWorldObject():isDestructible() then
            -- TODO: Applay damage to worldObject's health.
            worldObject = nil;
            self:setDirty( true );
        end
    end

    function self:removeCharacter()
        character = nil;
        self:setDirty( true );
    end

    function self:removeWorldObject()
        worldObject = nil;
    end

    -- ------------------------------------------------
    -- Getters
    -- ------------------------------------------------

    function self:getCharacter()
        return character;
    end

    function self:getID()
        return id;
    end

    function self:getMovementCost()
        if self:hasWorldObject() then
            return worldObject:getMovementCost();
        end
        return movementCost;
    end

    function self:getNeighbours()
        return neighbours;
    end

    function self:getPosition()
        return x, y;
    end

    function self:getType()
        return type;
    end

    function self:getWorldObject()
        return worldObject;
    end

    function self:getX()
        return x;
    end

    function self:getY()
        return y;
    end

    function self:hasWorldObject()
        return worldObject ~= nil;
    end

    function self:isAdjacent( tile )
        for _, neighbour in pairs( neighbours ) do
            if neighbour == tile then
                return true;
            end
        end
    end

    function self:isDirty()
        return dirty;
    end

    function self:isExplored()
        return explored;
    end

    function self:isOccupied()
        return character ~= nil;
    end

    function self:isPassable()
        if self:hasWorldObject() then
            return worldObject:isPassable();
        else
            return true;
        end
    end

    function self:isVisible()
        return visible;
    end

    -- ------------------------------------------------
    -- Setters
    -- ------------------------------------------------

    function self:setDirty( ndirty )
        dirty = ndirty;
    end

    function self:setExplored( nexplored )
        explored = nexplored;
    end

    function self:setID( nid )
        id = nid;
    end

    function self:setVisible( nvisible )
        visible = nvisible;
    end

    return self;
end

return Tile;
