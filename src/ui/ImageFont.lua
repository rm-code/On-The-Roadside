local ImageFont = {};

local IMAGE_SOURCE = 'res/img/imagefont8x16.png';
local GLYPH_DEFINITION = ' ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.,:;!?-+/()[]%&"\'*=_<>';

local font = love.graphics.newImageFont( IMAGE_SOURCE, GLYPH_DEFINITION );

function ImageFont.setFont()
    love.graphics.setFont( font );
end

function ImageFont.getFont()
    return font;
end

return ImageFont;
