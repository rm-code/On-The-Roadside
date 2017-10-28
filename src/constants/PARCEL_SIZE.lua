local PARCEL_SIZE = {}

PARCEL_SIZE.WIDTH  = 8
PARCEL_SIZE.HEIGHT = 8

-- Make table read-only.
return setmetatable( PARCEL_SIZE, {
    __index = function( _, key )
        error( "Can't access constant value at key: " .. key )
    end,
    __newindex = function()
        error( "Can't change a constant value." )
    end
})
