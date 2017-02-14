local Log = require( 'src.util.Log' );
local Object = require( 'src.Object' );

local BodyPart = {};

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function BodyPart.new( index, template )
    local self = Object.new():addInstance( 'BodyPart' );

    local health = template.health;
    local maxHealth = health;

    local bleeding = false;
    local bloodLoss = 0;

    function self:hit( damage, damageType )
        health = health - damage;
        Log.debug( string.format( 'Hit %s with %d points of %s damage. New hp: %d', template.id, damage, damageType, health ), 'BodyPart' );

        if self:isEntryNode() then
            -- TODO base bleeding on damage type.
            bleeding = true;
            bloodLoss = bloodLoss + love.math.random();
        end
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

    function self:getEffects()
        return template.effects;
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

    function self:getHealth()
        return health;
    end

    function self:getMaxHealth()
        return maxHealth;
    end

    function self:setHealth( nhealth )
        health = nhealth;
    end

    function self:isBleeding()
        return bleeding;
    end

    function self:getBloodLoss()
        return bloodLoss;
    end

    return self;
end

return BodyPart;
