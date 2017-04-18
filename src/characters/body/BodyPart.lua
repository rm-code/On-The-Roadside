local Log = require( 'src.util.Log' );
local Object = require( 'src.Object' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BodyPart = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local DAMAGE_TYPES = require( 'src.constants.DAMAGE_TYPES' );

local RND_DAMAGE_PICKER = {
    DAMAGE_TYPES.SLASHING,
    DAMAGE_TYPES.PIERCING,
    DAMAGE_TYPES.BLUDGEONING
}

local BLEEDING_CHANCE = {
    [DAMAGE_TYPES.SLASHING]    = 90,
    [DAMAGE_TYPES.PIERCING]    = 60,
    [DAMAGE_TYPES.BLUDGEONING] = 20
}

local BLEEDING_AMOUNT = {
    [DAMAGE_TYPES.SLASHING]    = 1.2,
    [DAMAGE_TYPES.PIERCING]    = 1.0,
    [DAMAGE_TYPES.BLUDGEONING] = 0.9
}

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function BodyPart.new( index, template )
    local self = Object.new():addInstance( 'BodyPart' );

    local health = template.health;
    local maxHealth = health;

    local bleeding = false;
    local bloodLoss = 0;

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    ---
    -- Returns a random sign.
    -- @return (number) Either one or minus one.
    --
    local function randomSign()
        return love.math.random( 0, 1 ) == 0 and -1 or 1;
    end

    local function bleed( damage, damageType )
        local chance = BLEEDING_CHANCE[damageType];
        if love.math.random( 100 ) < chance then
            bleeding = true;
            local fluffModifier = 1 + randomSign() * ( love.math.random( 50 ) / 100 );
            bloodLoss = bloodLoss + (( damage / health ) * fluffModifier * BLEEDING_AMOUNT[damageType] );
        end
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:hit( damage, damageType )
        -- Transform explosive damage to one of the other three damage types.
        if damageType == DAMAGE_TYPES.EXPLOSIVE then
            damageType = RND_DAMAGE_PICKER[love.math.random( #RND_DAMAGE_PICKER )];
        end

        health = health - damage;
        Log.debug( string.format( 'Hit %s with %d points of %s damage. New hp: %d', template.id, damage, damageType, health ), 'BodyPart' );

        -- Bleeding only affects entry nodes (since they are visible to the player).
        if self:isEntryNode() then
            bleed( damage, damageType );
        end
    end

    function self:destroy()
        health = 0;
    end

    function self:serialize()
        local t = {
            ['id'] = template.id,
            ['health'] = health,
            ['maxHealth'] = maxHealth,
            ['bleeding'] = bleeding,
            ['bloodLoss'] = bloodLoss
        };
        return t;
    end

    function self:load( savedBodyPart )
        health = savedBodyPart.health;
        maxHealth = savedBodyPart.maxHealth;
        bleeding = savedBodyPart.bleeding;
        bloodLoss = savedBodyPart.bloodLoss;
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

    function self:heal()
        bleeding = false
        bloodLoss = 0
        health = maxHealth
    end

    return self;
end

return BodyPart;
