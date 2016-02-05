local COLORS = {};

-- Base 16 - Ashes (https://github.com/chriskempson/base16)
COLORS.BASE00 = {  28,  32,  35, 255 };
COLORS.BASE01 = {  57,  63,  69, 255 };
COLORS.BASE02 = {  86,  94, 101, 255 };
COLORS.BASE03 = { 116, 124, 132, 255 };
COLORS.BASE04 = { 173, 179, 186, 255 };
COLORS.BASE05 = { 199, 204, 209, 255 };
COLORS.BASE06 = { 223, 226, 229, 255 };
COLORS.BASE07 = { 243, 244, 245, 255 };
COLORS.BASE08 = { 199, 174, 149, 255 };
COLORS.BASE09 = { 199, 199, 149, 255 };
COLORS.BASE0A = { 174, 199, 149, 255 };
COLORS.BASE0B = { 149, 199, 174, 255 };
COLORS.BASE0C = { 149, 174, 199, 255 };
COLORS.BASE0D = { 174, 149, 199, 255 };
COLORS.BASE0E = { 199, 149, 174, 255 };
COLORS.BASE0F = { 199, 149, 149, 255 };

-- Make table read-only.
return setmetatable( COLORS, {
    __index = function( _, key )
        error( "Can't access constant value at key: " .. key );
    end,
    __newindex = function()
        error( "Can't change a constant value." );
    end
} );
