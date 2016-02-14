local FACTIONS = {};

FACTIONS.ALLIED  = 1;
FACTIONS.NEUTRAL = 2;
FACTIONS.ENEMY   = 3;

-- Make table read-only.
return setmetatable( FACTIONS, {
    __index = function( _, key )
        error( "Can't access constant value at key: " .. key );
    end,
    __newindex = function()
        error( "Can't change a constant value." );
    end
} );
