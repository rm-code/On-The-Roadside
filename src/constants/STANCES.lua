local STANCES = {}

STANCES.STAND  = 'stand'
STANCES.CROUCH = 'crouch'
STANCES.PRONE  = 'prone'

-- Make table read-only.
return setmetatable( STANCES, {
    __index = function( _, key )
        error( "Can't access constant value at key: " .. key )
    end,
    __newindex = function()
        error( "Can't change a constant value." )
    end
})
