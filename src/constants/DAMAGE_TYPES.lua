local DAMAGE_TYPES = {};

DAMAGE_TYPES.PIERCING = 'piercing';
DAMAGE_TYPES.SLASHING = 'slashing';
DAMAGE_TYPES.BLUDGEONING = 'bludgeoning';
DAMAGE_TYPES.EXPLOSIVE = 'explosive';

-- Make table read-only.
return setmetatable( DAMAGE_TYPES, {
    __index = function( _, key )
        error( "Can't access constant value at key: " .. key );
    end,
    __newindex = function()
        error( "Can't change a constant value." );
    end
} );
