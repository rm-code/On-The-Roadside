---
-- @module Particle
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Particle = Class( 'Particle' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function Particle:update( dt )
    self.a = self.a - dt * self.fade
end

function Particle:getColors()
    return self.r, self.g, self.b, self.a
end

function Particle:getAlpha()
    return self.a
end

function Particle:getSprite()
    return self.sprite
end

function Particle:setParameters( r, g, b, a, fade, sprite )
    self.r, self.g, self.b, self.a, self.fade, self.sprite = r, g, b, a, fade, sprite
end

function Particle:clear()
    self.r, self.g, self.b, self.a, self.fade, self.sprite = nil, nil, nil, nil, nil, nil
end

return Particle
