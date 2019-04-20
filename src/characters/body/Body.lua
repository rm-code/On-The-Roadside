---
-- The Body module is used to keep track of a creature's body parts and health
-- related stats. Each Body in the game is modelled as a graph with nodes being
-- the body parts and edges determining how the different parts are connected.
--
-- The body also contains a creature's the inventory and equipment.
--
-- @module Body
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )
local Observable = require( 'src.util.Observable' )
local StatusEffects = require( 'src.characters.body.StatusEffects' )
local Armor = require( 'src.items.Armor' )
local Util = require( 'src.util.Util' )
local Translator = require( 'src.util.Translator' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Body = Observable:subclass( 'Body' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local STATUS_EFFECTS = require( 'src.constants.STATUS_EFFECTS' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Checks if the body part is connected to an equipment slot containing an armor
-- item.
-- @tparam Equipment equipment The creature's equipment.
-- @tparam table bodyPart The body part to check armor protection for.
-- @tparam number damage The damage to modify if the armor protects it.
-- @treturn number The modified damage value.
--
local function checkArmorProtection( equipment, bodyPart, damage )
    local slot = equipment:getSlot( bodyPart.equipment )
    assert( slot, string.format( 'No equipment slot assigned to [%s].', bodyPart.name ))

    local item = slot:getItem()
    if item and item:isInstanceOf( Armor ) then
        Log.debug( string.format( 'Body part is protected by armor [%s].', item:getID() ), 'Body' )
        if love.math.random( 0, 100 ) < item:getArmorCoverage() then
            Log.debug( string.format( 'The armor absorbs %d points of damage.', item:getArmorProtection() ), 'Body' )
            return math.max( 0, damage - item:getArmorProtection() )
        end
    end
    return damage
end

---
-- Applies a modifier to the damage value and floors it.
-- @tparam number damage The damage value to modify.
-- @tparam number modifier The modifier to apply.
-- @treturn number The modified damage value.
--
local function modifyDamage( damage, modifier )
    return math.floor( damage * modifier )
end

---
-- @tparam StatusEffects statusEffects
-- @tparam number damage
-- @tparam table effects
--
local function handleCriticalHits( statusEffects, damage, effects )
    -- Attacks which don't deal damage can't be a critical hit.
    if damage <= 0 then
        return
    end

    -- Some body parts don't have any status effects assigned to them.
    if not effects then
        return
    end

    -- TODO Use percentage based on weapon stats.
    if love.math.random( 100 ) <= 5 then
        statusEffects:add({ Util.pickRandomValue( effects )})
    end
end

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- Initializes the Body instance.
-- @tparam string id          The creature's id.
-- @tparam number hp          The creature's health points.
-- @tparam table  tags        The creature's tags.
-- @tparam table  sizes       A table containing the creature's sizes mapped to its stances.
-- @tparam Equipment equipment The creature's equipment.
-- @tparam Inventory inventory The creature's inventory.
-- @tparam table bodyParts A table containing the creature's body parts.
--
function Body:initialize( id, hp, tags, sizes, bodyParts, equipment, inventory )
    Observable.initialize( self )

    self.id = id

    self.currentHP = hp
    self.maximumHP = hp

    self.tags = tags
    self.sizes = sizes

    self.equipment = equipment
    self.inventory = inventory

    self.bodyParts = bodyParts

    self.statusEffects = StatusEffects()
    self.statusEffects:observe( self )
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Selects a random entry point for the damage and then propagates it along the
-- connections to the appropriate body parts.
-- @tparam number damage     The damage to apply to the body.
-- @tparam string damageType The type of damage to apply.
--
function Body:hit( damage, _ )
    local bodyPart = Util.pickRandomValue( self.bodyParts )

    -- Apply the body part's damage modifier.
    damage = modifyDamage( damage, bodyPart.damageModifier )

    -- Reduce the damage if the body part is protected by armor.
    damage = checkArmorProtection( self.equipment, bodyPart, damage )

    -- Apply the damage to the hp.
    self.currentHP = self.currentHP - damage

    self:publish( 'MESSAGE_LOG_EVENT', string.format( Translator.getText( 'msg_body_hit' ), Translator.getText( bodyPart.name ), damage ), 'WARNING' )

    handleCriticalHits( self.statusEffects, damage, bodyPart.effects )

    -- Kill the character if health drops below zero.
    if self.currentHP <= 0 then
        self.statusEffects:add({ STATUS_EFFECTS.DEAD })
    end

    Log.debug( string.format( "Attack hits body with %d of damage (%s), New hp: %s!", damage, bodyPart.name, self.currentHP ), 'Body' )
end

---
-- Serializes the Body.
--
function Body:serialize()
    local t = {
        ['id'] = self.id,
        ['currentHP'] = self.currentHP,
        ['maximumHP'] = self.maximumHP,
        ['inventory'] = self.inventory:serialize(),
        ['equipment'] = self.equipment:serialize(),
        ['statusEffects'] = self.statusEffects:serialize()
    }
    return t
end

---
-- Receives events by observed objects.
-- @tparam string event The event type.
-- @tparam varags ... Additional parameters to pass along.
--
function Body:receive( event, ... )
    self:publish( event, ... )
end

-- ------------------------------------------------
-- Setters
-- ------------------------------------------------

---
-- Sets the current health points.
-- @tparam number hp The new health points value.
--
function Body:setCurrentHP( hp )
    self.currentHP = hp
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

---
-- Returns the creature's equipment.
-- @treturn Equipment The equipment.
--
function Body:getEquipment()
    return self.equipment
end

---
-- Returns the creature's health.
-- @treturn number The current health points.
--
function Body:getCurrentHP()
    return self.currentHP
end

---
-- Returns the creature's maximum health.
-- @treturn number The maximum health points.
--
function Body:getMaximumHP()
    return self.maximumHP
end

---
-- Returns the creature's height based on a certain stance.
-- @tparam  string stance The stance to get the height for.
-- @treturn number        The height based on the stance.
--
function Body:getHeight( stance )
    return self.sizes[stance]
end

---
-- Returns the creature's id.
-- @treturn string The creature's id.
function Body:getID()
    return self.id
end

---
-- Returns the creature's inventory.
-- @treturn Inventory The inventory.
--
function Body:getInventory()
    return self.inventory
end

---
-- Returns the active status effects.
-- @treturn StatusEffects The status effects for this body.
--
function Body:getStatusEffects()
    return self.statusEffects
end

---
-- Returns the body's tags.
-- @treturn table The body's tags.
--
function Body:getTags()
    return self.tags
end

return Body
