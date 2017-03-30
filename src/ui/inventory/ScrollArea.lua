local Object = require( 'src.Object' );
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

local ScrollArea = {};

function ScrollArea.new( x, y, w, h )
    local self = Object.new():addInstance( 'ScrollArea' );

    local text;
    local _, lines;
    local verticalOffset = 0;
    local tileset = TexturePacks.getTileset()
    local font = TexturePacks.getFont()
    local tw, th = tileset:getTileDimensions()

    function self:setText( ntext )
        text = ntext;
        _, lines = font:get():getWrap( text, w * tw - tw )
    end

    local function drawScrollBar()
        if not lines or #lines < h then
            return;
        end

        if verticalOffset < 0 then
            love.graphics.draw( tileset:getSpritesheet(), tileset:getSprite( 31 ), (x + w - 2) * tw, ( y - 2 ) * th )
        end

        if verticalOffset > h - #lines then
            love.graphics.draw( tileset:getSpritesheet(), tileset:getSprite( 32 ), (x + w - 1) * tw, ( y - 2 ) * th )
        end
    end

    function self:draw()
        love.graphics.setScissor( x * tw, y * th, w * tw, h * th )
        for i = 1, #lines do
            love.graphics.print( lines[i], x * tw, ( y + i - 1 + verticalOffset ) * th )
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
        _, lines = font:get():getWrap( text, w * tw - tw )
    end

    return self;
end

return ScrollArea;
