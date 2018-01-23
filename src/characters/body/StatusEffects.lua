---
-- This module keeps track of the different status effects applied to a
-- character's body.
-- @module StatusEffects
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Observable = require( 'src.util.Observable' )
local Translator = require( 'src.util.Translator' )
local Log = require( 'src.util.Log' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local StatusEffects = Observable:subclass( 'StatusEffects' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local STATUS_EFFECTS = require( 'src.constants.STATUS_EFFECTS' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Makes sure the applied status effect is from the actual list of status
-- effects.
-- @tparam  string effect The effect to check.
-- @treturn boolean       True if the status effect is valid.
--
local function validate( effect )
    for _, constant in pairs( STATUS_EFFECTS ) do
        if effect == constant then
            return true
        end
    end
    return false
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Initializes a new StatusEffects instance.
--
function StatusEffects:initialize()
    Observable.initialize( self )
    self.active = {}
end

---
-- Adds one or more status effects.
-- @tparam table effects A table containing the status effects to apply.
--
function StatusEffects:add( effects )
    if not effects then
        return
    end

    for _, effect in pairs( effects ) do
        assert( validate( effect ), string.format( 'Status effect %s is not valid.', effect ))

        -- Only apply status effect if it isn't active already.
        if not self.active[effect] then
            self:publish( 'MESSAGE_LOG_EVENT', string.format( Translator.getText( 'msg_status_effect' ), Translator.getText( effect )), 'WARNING' )

            Log.debug( 'Apply status effect ' .. effect )
            self.active[effect] = true
        end
    end
end

---
-- Removes one or more status effects.
-- @tparam table effects A table containing the status effects to remove.
--
function StatusEffects:remove( effects )
    if not effects then
        return
    end

    for _, effect in pairs( effects ) do
        assert( validate( effect ), string.format( 'Status effect %s is not valid.', effect ))

        Log.debug( 'Removing status effect ' .. effect )
        self.active[effect] = false
    end
end

---
-- Serializes this object.
-- @treturn table A table containing the serialized values.
--
function StatusEffects:serialize()
    local t = {}
    for effect, boolean in pairs( self.active ) do
        t[effect] = boolean
    end
    return t
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

---
-- Returns wether the character is dead.
-- @treturn boolean Wether the character is dead or not.
--
function StatusEffects:isDead()
    return self.active[STATUS_EFFECTS.DEAD]
end

---
-- Returns wether the character is blind.
-- @treturn boolean Wether the character is blind or not.
--
function StatusEffects:isBlind()
    return self.active[STATUS_EFFECTS.BLIND]
end

---
-- Returns a list of active status effects.
-- @treturn table The active status effects.
--
function StatusEffects:getActiveEffects()
    return self.active
end

return StatusEffects
