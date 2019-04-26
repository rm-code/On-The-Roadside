---
-- @module Projectile
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Projectile = Class( 'Projectile' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local DEFAULT_SPEED = 30

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Initializes a new Projectile object.
-- @tparam Character         character  The character this projectile belongs to.
-- @tparam table             tiles      A sequence containing all tiles this projectile will pass.
-- @tparam number            damage     The damage this projectile deals.
-- @tparam string            damageType The type of damage the tile is hit with.
-- @tparam AmmunitionEffects effects    An object containing different effects associated with ammunition.
--
function Projectile:initialize( character, tiles, damage, damageType, effects )
    self.character = character
    self.tiles = tiles
    self.damage = damage
    self.damageType = damageType
    self.effects = effects

    self.timer = 0
    self.index = 1
    self.tile = character:getTile()
    self.speed = effects:hasCustomSpeed() and effects:getCustomSpeed() or DEFAULT_SPEED
end

---
-- Advances the projectile to the next tile in its queue if the timer is
-- reached. Different types of projectiles can have different speeds.
-- @tparam number dt The time since the last frame update.
--
function Projectile:update( dt )
    self.timer = self.timer + dt * self.speed
    if self.timer > 1 and self.index < #self.tiles then
        self.index = self.index + 1
        self.timer = 0
    end

    if self.effects:hasCustomSpeed() then
        self.speed = math.min( self.speed + self.effects:getSpeedIncrease(), self.effects:getFinalSpeed() )
    end
end

---
-- Moves the projectile to the next tile.
-- @tparam Map map The game's map.
--
function Projectile:updateTile( map )
    self.previousTile = self.tile
    self.tile = map:getTileAt( self.tiles[self.index].x, self.tiles[self.index].y )
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

function Projectile:getCharacter()
    return self.character
end

function Projectile:getEffects()
    return self.effects
end

function Projectile:getDamage()
    return self.damage
end

function Projectile:getDamageType()
    return self.damageType
end

function Projectile:getTile()
    return self.tile
end

function Projectile:getPreviousTile()
    return self.previousTile
end

function Projectile:hasMoved( map )
    return self.tile ~= map:getTileAt( self.tiles[self.index].x, self.tiles[self.index].y )
end

function Projectile:hasReachedTarget()
    return #self.tiles == self.index
end

function Projectile:getHeight()
    return self.tiles[self.index].z
end

return Projectile
