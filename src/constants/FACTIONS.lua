local FACTIONS = {};

FACTIONS.ALLIED  = 'allied';
FACTIONS.NEUTRAL = 'neutral';
FACTIONS.ENEMY   = 'enemy';

-- Make table read-only.
return setmetatable( FACTIONS, {
    __index = function( _, key )
        error( "Can't access constant value at key: " .. key );
    end,
    __newindex = function()
        error( "Can't change a constant value." );
    end
} );
