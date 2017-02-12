local ITEM_TYPES = {};

ITEM_TYPES.WEAPON    = 'Weapon';
ITEM_TYPES.BAG       = 'Bag';
ITEM_TYPES.AMMO      = 'Ammunition';
ITEM_TYPES.HEADGEAR  = 'Headgear';
ITEM_TYPES.GLOVES    = 'Gloves';
ITEM_TYPES.JACKET    = 'Jacket';
ITEM_TYPES.SHIRT     = 'Shirt';
ITEM_TYPES.TROUSERS  = 'Trousers';
ITEM_TYPES.FOOTWEAR  = 'Footwear';
ITEM_TYPES.MISC      = 'Miscellaneous';

-- Make table read-only.
return setmetatable( ITEM_TYPES, {
    __index = function( _, key )
        error( "Can't access constant value at key: " .. key );
    end,
    __newindex = function()
        error( "Can't change a constant value." );
    end
} );
