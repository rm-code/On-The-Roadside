---
-- @module Pulser
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Pulser = Class( 'Middleclass' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function Pulser:initialize( speed, offset, range )
    self.speed = speed or 1
    self.offset = offset or 1
    self.range = range or 1

    self.timer = 0
    self.value = 0
end

---
-- Returns gradually changing values between 0 and 1 which can be used to
-- make elements slowly pulsate.
-- @tparam number dt The time since the last update in seconds.
--
function Pulser:update( dt )
    self.timer = self.timer + dt * self.speed
    self.value = math.abs( math.sin( self.timer )) * self.range + self.offset
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

---
-- Returns the pulse value.
-- @treturn number A value between 0 and 1.
--
function Pulser:getPulse()
    return self.value
end

return Pulser
