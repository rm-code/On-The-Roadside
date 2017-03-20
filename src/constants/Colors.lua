local COLORS = {};

-- DawnBringer's 32 Col Palette V1.0
-- @see http://pixeljoint.com/forum/forum_posts.asp?TID=16247
COLORS.DB00 = {   0,   0,   0 };
COLORS.DB01 = {  34,  32,  52 };
COLORS.DB02 = {  69,  40,  60 };
COLORS.DB03 = { 102,  57,  49 };
COLORS.DB04 = { 143,  86,  59 };
COLORS.DB05 = { 223, 113,  38 };
COLORS.DB06 = { 217, 160, 102 };
COLORS.DB07 = { 238, 195, 154 };
COLORS.DB08 = { 251, 242,  54 };
COLORS.DB09 = { 153, 229,  80 };
COLORS.DB10 = { 106, 190,  48 };
COLORS.DB11 = {  55, 148, 110 };
COLORS.DB12 = {  75, 105,  47 };
COLORS.DB13 = {  82,  75,  36 };
COLORS.DB14 = {  50,  60,  57 };
COLORS.DB15 = {  63,  63, 116 };
COLORS.DB16 = {  48,  96, 130 };
COLORS.DB17 = {  91, 110, 225 };
COLORS.DB18 = {  99, 155, 255 };
COLORS.DB19 = {  95, 205, 228 };
COLORS.DB20 = { 203, 219, 252 };
COLORS.DB21 = { 255, 255, 255 };
COLORS.DB22 = { 155, 173, 183 };
COLORS.DB23 = { 132, 126, 135 };
COLORS.DB24 = { 105, 106, 106 };
COLORS.DB25 = {  89,  86,  82 };
COLORS.DB26 = { 118,  66, 138 };
COLORS.DB27 = { 172,  50,  50 };
COLORS.DB28 = { 217,  87,  99 };
COLORS.DB29 = { 215, 123, 186 };
COLORS.DB30 = { 143, 151,  74 };
COLORS.DB31 = { 138, 111,  48 };
COLORS.RESET = { 255, 255, 255, 255 };

-- Make table read-only.
return setmetatable( COLORS, {
    __index = function( _, key )
        error( "Can't access constant value at key: " .. key );
    end,
    __newindex = function()
        error( "Can't change a constant value." );
    end
} );
