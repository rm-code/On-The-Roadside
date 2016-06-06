local CLOTHING_SLOTS = {};

CLOTHING_SLOTS.HEADGEAR = 'Headgear';
CLOTHING_SLOTS.GLOVES   = 'Gloves';
CLOTHING_SLOTS.JACKET   = 'Shirt';
CLOTHING_SLOTS.SHIRT    = 'Jacket';
CLOTHING_SLOTS.TROUSERS = 'Trousers';
CLOTHING_SLOTS.FOOTWEAR = 'Footwear';

-- Make table read-only.
return setmetatable( CLOTHING_SLOTS, {
    __index = function( _, key )
        error( "Can't access constant value at key: " .. key );
    end,
    __newindex = function()
        error( "Can't change a constant value." );
    end
} );
