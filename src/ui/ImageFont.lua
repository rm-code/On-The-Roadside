local ImageFont = {};

local IMAGE_SOURCE = 'res/img/imagefont8x16.png';
local GLYPH_DEFINITION = ' ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.,:;!?-+/()[]%&"\'*=_<>ß^';
local GLYPH_WIDTH = 8;
local GLYPH_HEIGHT = 16;

local font = love.graphics.newImageFont( IMAGE_SOURCE, GLYPH_DEFINITION );

function ImageFont.set()
    love.graphics.setFont( font );
end

function ImageFont.get()
    return font;
end

function ImageFont.measureWidth( str )
    return font:getWidth( str );
end

function ImageFont.getGlyphWidth()
    return GLYPH_WIDTH;
end

function ImageFont.getGlyphHeight()
    return GLYPH_HEIGHT;
end

return ImageFont;
