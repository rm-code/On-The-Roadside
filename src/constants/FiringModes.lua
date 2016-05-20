local FIRING_MODES = {};

FIRING_MODES.SINGLE = 'single';
FIRING_MODES.BURST  = 'burst';
FIRING_MODES.AUTO   = 'auto';

-- Make table read-only.
return setmetatable( FIRING_MODES, {
    __index = function( _, key )
        error( "Can't access constant value at key: " .. key );
    end,
    __newindex = function()
        error( "Can't change a constant value." );
    end
} );
