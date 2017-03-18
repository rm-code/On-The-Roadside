local STATUS_EFFECTS = {};

STATUS_EFFECTS.DEATH     = 'death';
STATUS_EFFECTS.BLINDNESS = 'blindness';

-- Make table read-only.
return setmetatable( STATUS_EFFECTS, {
    __index = function( _, key )
        error( "Can't access constant value at key: " .. key );
    end,
    __newindex = function()
        error( "Can't change a constant value." );
    end
} );
