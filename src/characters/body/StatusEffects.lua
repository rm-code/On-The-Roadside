---
-- This module keeps track of the different status effects applied to a
-- character's body.
-- @module StatusEffects
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )
local Object = require( 'src.Object' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local StatusEffects = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local STATUS_EFFECTS = require( 'src.constants.STATUS_EFFECTS' )

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function StatusEffects.new()
    local self = Object.new():addInstance( 'StatusEffects' )

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local active = {}

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
    -- Adds one or more status effects.
    -- @tparam table effects A table containing the status effects to apply.
    --
    function self:add( effects )
        if not effects then
            return
        end

        for _, effect in pairs( effects ) do
            assert( validate( effect ), string.format( 'Status effect %s is not valid.', effect ))

            -- Only apply status effect if it isn't active already.
            if not active[effect] then
                Log.debug( 'Apply status effect ' .. effect )
                active[effect] = true
            end
        end
    end

    ---
    -- Serializes this object.
    -- @treturn table A table containing the serialized values.
    --
    function self:serialize()
        local t = {}
        for effect, boolean in pairs( active ) do
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
    function self:isDead()
        return active[STATUS_EFFECTS.DEATH]
    end

    ---
    -- Returns wether the character is blind.
    -- @treturn boolean Wether the character is blind or not.
    --
    function self:isBlind()
        return active[STATUS_EFFECTS.BLINDNESS]
    end

    return self
end

return StatusEffects
