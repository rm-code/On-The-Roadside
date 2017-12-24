---
-- @module ParticleLayer
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local Messenger = require( 'src.Messenger' )
local Particle = require( 'src.ui.overlays.Particle' )
local ObjectPool = require( 'src.util.ObjectPool' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ParticleLayer = Class( 'ParticleLayer' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

local function addParticleEffect( grid, particles, x, y, r, g, b, a, fade, sprite )
    grid[x] = grid[x] or {}
    -- Return previous particles on this tile to the particle pool.
    if grid[x][y] then
        particles:deposit( grid[x][y] )
    end
    grid[x][y] = particles:request( r, g, b, a, fade, sprite )
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function ParticleLayer:initialize()
    self.grid = {}
    self.particles = ObjectPool( Particle )

    Messenger.observe( 'PROJECTILE_MOVED', function( ... )
        local projectile = ...
        local tile = projectile:getTile()
        if tile then
            if projectile:getEffects():hasCustomSprite() then
                addParticleEffect( self.grid, self.particles, tile:getX(), tile:getY(), 255, 255, 255, 255, 1500, projectile:getEffects():getCustomSprite() )
            elseif projectile:getEffects():isExplosive() then
                local col = love.math.random( 150, 255 )
                addParticleEffect( self.grid, self.particles, tile:getX(), tile:getY(), col, col, col, love.math.random( 100, 255 ), 500 )
            else
                addParticleEffect( self.grid, self.particles, tile:getX(), tile:getY(), 223, 113,  38, 200, 500 )
            end
        end
    end)

    Messenger.observe( 'EXPLOSION', function( ... )
        local generation = ...
        for tile, life in pairs( generation ) do
            local r = 255
            local g = love.math.random( 100, 200 )
            local b = 0
            local a = love.math.random( 200, 255 )
            local fade = 500 / math.min( 3, love.math.random( life ))
            addParticleEffect( self.grid, self.particles, tile:getX(), tile:getY(), r, g, b, a, fade )
        end
    end)
end

function ParticleLayer:update( dt )
    for x, row in pairs( self.grid ) do
        for y, particle in pairs( row ) do
            particle:update( dt )

            -- Remove the Particle if it is invisible.
            if particle:getAlpha() <= 0 then
                self.particles:deposit( particle )
                self.grid[x][y] = nil
            end
        end
    end
end

function ParticleLayer:getParticleGrid()
    return self.grid
end

return ParticleLayer
