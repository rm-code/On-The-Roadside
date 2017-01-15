local Object = require( 'src.Object' );

local BodyPart = {};

function BodyPart.new( index, template )
    local self = Object.new():addInstance( 'BodyPart' );

    local health = template.health;

    function self:hit( damage, damageType )
        health = health - damage;
        print( string.format( 'Hit %s with %d points of %s damage. New hp: %d', template.id, damage, damageType, health ));
    end

    function self:destroy()
        health = 0;
    end

    function self:getIndex()
        return index;
    end

    function self:getID()
        return template.id;
    end

    function self:getType()
        return template.type;
    end

    function self:isVital()
        return template.vital;
    end

    function self:isVisual()
        return template.visual;
    end

    function self:isDestroyed()
        return health <= 0;
    end

    function self:isEntryNode()
        return template.type == 'entry';
    end

    function self:isContainer()
        return template.type == 'container';
    end

    function self:setHealth( nhealth )
        health = nhealth;
    end

    return self;
end

return BodyPart;