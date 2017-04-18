local WEAPON_TYPES = {}

WEAPON_TYPES.MELEE  = 'Melee'
WEAPON_TYPES.RANGED = 'Ranged'
WEAPON_TYPES.THROWN = 'Thrown'

-- Make table read-only.
return setmetatable( WEAPON_TYPES, {
    __index = function( _, key )
        error( "Can't access constant value at key: " .. key )
    end,
    __newindex = function()
        error( "Can't change a constant value." )
    end
})
