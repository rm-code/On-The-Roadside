local Log = require( 'src.util.Log' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Tileset = {};

-- ------------------------------------------------
-- Local Variables
-- ------------------------------------------------

local tileset;
local sprites;

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

function Tileset.init( imageUrl, tilesize )
    tileset = love.graphics.newImage( imageUrl );
    sprites = {};
    for x = 1, tileset:getWidth() / tilesize do
        for y = 1, tileset:getHeight() / tilesize do
            sprites[#sprites + 1] = love.graphics.newQuad(( y - 1 ) * tilesize, ( x - 1 ) * tilesize, tilesize, tilesize, tileset:getDimensions() );
        end
    end
    Log.info( string.format( 'Loaded %d sprites!', #sprites ), 'Tileset' );
end

-- ------------------------------------------------
-- Getters
-- ------------------------------------------------

function Tileset.getSprite( number )
    return sprites[number];
end

function Tileset.getTileset()
    return tileset;
end

return Tileset;
