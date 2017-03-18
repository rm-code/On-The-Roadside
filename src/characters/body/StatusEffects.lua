local Log = require( 'src.util.Log' );
local Object = require( 'src.Object' );

local STATUS_EFFECTS = require( 'src.constants.StatusEffects' );

local StatusEffects = {};

function StatusEffects.new()
    local self = Object.new():addInstance( 'StatusEffects' );

    local active = {};

    local function validate( effect )
        local valid = false;
        for _, constant in pairs( STATUS_EFFECTS ) do
            if effect == constant then
                valid = true;
            end
        end
        return valid;
    end

    function self:add( effects )
        if not effects then
            return;
        end

        for _, effect in pairs( effects ) do
            local valid = validate( effect );
            assert( valid, string.format( "Status effect %s is not valid.", effect ));
            Log.debug( 'Apply status effect ' .. effect );
            active[effect] = true;
        end
    end

    -- Getters
    function self:isDead()
        return active[STATUS_EFFECTS.DEATH];
    end

    function self:isBlind()
        return active[STATUS_EFFECTS.BLINDNESS];
    end

    return self;
end

return StatusEffects;
