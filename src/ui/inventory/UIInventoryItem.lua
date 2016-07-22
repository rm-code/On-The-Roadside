local Object = require( 'src.Object' );

local UIInventoryItem = {};

local COLORS = require( 'src.constants.Colors' );
local WIDTH  = 150;
local HEIGHT =  30;

function UIInventoryItem.new( x, y, item )
    local self = Object.new():addInstance( 'UIInventoryItem' );

    local mouseOver = false;

    function self:draw()
        if mouseOver then
            love.graphics.setColor( COLORS.DB15 );
        else
            love.graphics.setColor( COLORS.DB00 );
        end

        love.graphics.rectangle( 'fill', x, y, WIDTH, HEIGHT );

        love.graphics.setColor( COLORS.DB23 );
        love.graphics.rectangle( 'line', x, y, WIDTH, HEIGHT );

        love.graphics.setScissor( x, y, WIDTH, HEIGHT );
        love.graphics.setColor( COLORS.DB21 );
        love.graphics.printf( item and item:getName() or 'Empty', x, y + 5, WIDTH, 'center' );
        love.graphics.setScissor();
    end

    function self:update()
        local mx, my = love.mouse.getPosition();
        mouseOver = ( mx > x and mx < x + WIDTH and my > y and my < y + HEIGHT );
    end

    function self:isMouseOver()
        return mouseOver;
    end

    function self:drag()
        return item;
    end

    return self;
end

return UIInventoryItem;
