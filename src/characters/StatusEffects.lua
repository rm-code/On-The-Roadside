local Object = require( 'src.Object' );

local STATUS_EFFECTS = require( 'src.constants.StatusEffects' );

local StatusEffects = {};

function StatusEffects.new( body )
    local self = Object.new():addInstance( 'StatusEffects' );

    local active = {};
    local bleeding = {};
    local bleedingIndex = 0; -- Always increasing index.

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
            print( 'Apply status effect ' .. effect );
            active[effect] = true;
        end
    end

    function self:addBleeding( duration, amount, bodypart )
        bleedingIndex = bleedingIndex + 1;
        bleeding[bleedingIndex] = {
            duration = duration,
            amount = amount,
            bodypart = bodypart
        }
        print( string.format( 'Added bleeding effect - D: %1.1f, A: %1.1f, B: %s ', duration, amount, bodypart:getID() ));
    end

    function self:tickOneTurn()
        for i, effect in pairs( bleeding ) do
            print( string.format( 'Tick bleeding effect - D: %1.1f, A: %1.1f, B: %s ', effect.duration, effect.amount, effect.bodypart:getID() ));
            effect.duration = effect.duration - 1;
            body:reduceBloodVolume( effect.amount );

            -- Remove bleeding effect.
            if effect.duration == 0 then
                bleeding[i] = nil;
                print( 'Remove bleeding effect from ' .. effect.bodypart:getID() );
            end
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
