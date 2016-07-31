local STANCES = {};

STANCES.STAND  = 1;
STANCES.CROUCH = 2;
STANCES.PRONE  = 3;

-- Make table read-only.
return setmetatable( STANCES, {
    __index = function( _, key )
        error( "Can't access constant value at key: " .. key );
    end,
    __newindex = function()
        error( "Can't change a constant value." );
    end
} );
