local DIRECTION = {}

DIRECTION.NORTH      = 1
DIRECTION.NORTH_EAST = 2
DIRECTION.NORTH_WEST = 3
DIRECTION.SOUTH      = 4
DIRECTION.SOUTH_EAST = 5
DIRECTION.SOUTH_WEST = 6
DIRECTION.EAST       = 7
DIRECTION.WEST       = 8

-- Make table read-only.
return setmetatable( DIRECTION, {
    __index = function( _, key )
        error( "Can't access constant value at key: " .. key )
    end,
    __newindex = function()
        error( "Can't change a constant value." )
    end
})
