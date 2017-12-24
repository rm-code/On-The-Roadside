---
-- @module BodyPart
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local Log = require( 'src.util.Log' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BodyPart = Class( 'BodyPart' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local DAMAGE_TYPES = require( 'src.constants.DAMAGE_TYPES' )

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
-- Private Methods
-- ------------------------------------------------

---
-- Returns a random sign.
-- @return (number) Either one or minus one.
--
local function randomSign()
    return love.math.random( 0, 1 ) == 0 and -1 or 1
end

---
-- Randomly applies a bleeding effect. The chance is based on the damage type.
-- @tparam BodyPart self The BodyPart instance to use.
-- @tparam number damage     The amount of damage to apply.
-- @tparam string damageType The type of damage to apply.
--
local function bleed( self, damage, damageType )
    local chance = BLEEDING_CHANCE[damageType]
    if love.math.random( 100 ) < chance then
        self.bleeding = true
        local fluffModifier = 1 + randomSign() * ( love.math.random( 50 ) / 100 )
        self.bloodLoss = self.bloodLoss + (( damage / self.curHealth ) * fluffModifier * BLEEDING_AMOUNT[damageType] )
    end
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Initializes a new BodyPart instance.
-- @tparam number index     The BodyPart's index.
-- @tparam string id        The BodyPart's id.
-- @tparam string type      The BodyPart's type.
-- @tparam number maxHealth The BodyPart's maximum health.
-- @tparam table  effects   The effects to apply when the body part is destroyed.
--
function BodyPart:initialize( index, id, type, maxHealth, effects )
    self.index = index

    self.id = id
    self.type = type

    self.maxHealth = maxHealth
    self.curHealth = maxHealth

    self.effects = effects

    self.bleeding = false
    self.bloodLoss = 0
end

---
-- Hits the body part and applies bleeding effects.
-- @tparam number damage     The amount of damage to apply.
-- @tparam string damageType The type of damage to apply.
--
function BodyPart:hit( damage, damageType )
    -- Transform explosive damage to one of the other three damage types.
    if damageType == DAMAGE_TYPES.EXPLOSIVE then
        damageType = RND_DAMAGE_PICKER[love.math.random( #RND_DAMAGE_PICKER )]
    end

    self.curHealth = self.curHealth - damage
    Log.debug( string.format( 'Hit %s with %d points of %s damage. New hp: %d', self.id, damage, damageType, self.curHealth ), 'BodyPart' )

    -- Bleeding only affects entry nodes (since they are visible to the player).
    if self:isEntryNode() then
        bleed( self, damage, damageType )
    end
end

---
-- Destroys the body part.
--
function BodyPart:destroy()
    self.curHealth = 0
end

---
-- Serializes the body part.
--
function BodyPart:serialize()
    local t = {
        ['id'] = self.id,
        ['health'] = self.curHealth,
        ['maxHealth'] = self.maxHealth,
        ['bleeding'] = self.bleeding,
        ['bloodLoss'] = self.bloodLoss
    }
    return t
end

---
-- Restores a saved body part.
-- @tparam table savedBodyPart A table containing the saved values.
--
function BodyPart:load( savedBodyPart )
    self.curHealth = savedBodyPart.health
    self.maxHealth = savedBodyPart.maxHealth
    self.bleeding = savedBodyPart.bleeding
    self.bloodLoss = savedBodyPart.bloodLoss
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

---
-- Returns the body part's current health.
-- @treturn number The current health.
--
function BodyPart:getCurrentHealth()
    return self.curHealth
end

---
-- Returns the body part's maximum health.
-- @treturn number The maximum health.
--
function BodyPart:getMaximumHealth()
    return self.maxHealth
end

---
-- Returns the amount of blood loss currently active on this body part.
-- @treturn number The amount of blood loss.
--
function BodyPart:getBloodLoss()
    return self.bloodLoss
end

---
-- Returns the body part's index.
-- @treturn number The body part's index.
--
function BodyPart:getIndex()
    return self.index
end

---
-- Returns the body part's id.
-- @treturn string The body part's id.
--
function BodyPart:getID()
    return self.id
end

---
-- Returns the body part's status effects.
-- @treturn StatusEffects The body part's status effects.
--
function BodyPart:getEffects()
    return self.effects
end

---
-- Checks if the the body part is destroyed.
-- @treturn boolean Returns true if the body part is destroyed.
--
function BodyPart:isDestroyed()
    return self.curHealth <= 0
end

---
-- Checks if the body part is an entry node. Entry nodes are used to model
-- external body parts.
-- @treturn boolean True if the body part is an entry node.
--
function BodyPart:isEntryNode()
    return self.type == 'entry'
end

---
-- Checks if the body part is a container. Container nodes can contain other
-- body parts.
-- @treturn boolean True if the body part is a container node.
--
function BodyPart:isContainer()
    return self.type == 'container'
end

---
-- Checks if this body part is bleeding.
-- @treturn boolean True if the body part is bleeding.
--
function BodyPart:isBleeding()
    return self.bleeding
end

return BodyPart
