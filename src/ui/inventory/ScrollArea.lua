local Object = require( 'src.Object' );
local ImageFont = require( 'src.ui.ImageFont' );
local Tileset = require( 'src.ui.Tileset' );

local ScrollArea = {};

local TILE_SIZE = require( 'src.constants.TileSize' );

function ScrollArea.new( x, y, w, h )
    local self = Object.new():addInstance( 'ScrollArea' );

    local text;
    local _, lines;
    local verticalOffset = 0;
    local ts = Tileset.getTileset();

    function self:setText( ntext )
        text = ntext;
        _, lines = ImageFont.get():getWrap( text, w * TILE_SIZE - TILE_SIZE );
    end

    local function drawScrollBar()
        if not lines or #lines < h then
            return;
        end

        if verticalOffset < 0 then
            love.graphics.draw( ts, Tileset.getSprite( 31 ), (x + w - 2) * TILE_SIZE, ( y - 2 ) * TILE_SIZE );
        end

        if verticalOffset > h - #lines then
            love.graphics.draw( ts, Tileset.getSprite( 32 ), (x + w - 1) * TILE_SIZE, ( y - 2 ) * TILE_SIZE );
        end
    end

    function self:draw()
        love.graphics.setScissor( x * TILE_SIZE, y * TILE_SIZE, w * TILE_SIZE, h * TILE_SIZE );
        -- love.graphics.rectangle( 'fill', x * TILE_SIZE, y * TILE_SIZE, w * TILE_SIZE, h * TILE_SIZE );
        for i = 1, #lines do
            love.graphics.print( lines[i], x * TILE_SIZE, ( y + i - 1 + verticalOffset ) * TILE_SIZE );
        end

        love.graphics.setScissor();

        drawScrollBar();
    end

    function self:scrollVertically( dir )
        if not lines or #lines < h then
            return;
        end

        if dir == 1 and verticalOffset == 0 then
            return;
        end

        if dir == -1 and verticalOffset == h - #lines then
            return;
        end

        verticalOffset = verticalOffset + dir;
    end

    function self:setDimensions( nx, ny, nw, nh )
        x, y, w, h = nx, ny, nw, nh;
        _, lines = ImageFont.get():getWrap( text, w * TILE_SIZE - TILE_SIZE );
    end

    return self;
end

return ScrollArea;
