local ScreenManager = require( 'lib.screenmanager.ScreenManager' );
local Screen = require( 'lib.screenmanager.Screen' );
local CharacterManager = require( 'src.characters.CharacterManager' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local InventoryScreen = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local SCREEN_PADDING = 20;
local TEXT_PADDING = 20;

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function InventoryScreen.new()
    local self = Screen.new();

    local x = SCREEN_PADDING;
    local y = SCREEN_PADDING;

    function self:draw()
        love.graphics.setColor( 0, 0, 0 );
        love.graphics.rectangle( 'fill', x, y, love.graphics.getWidth() - x * 2, love.graphics.getHeight() - y * 2 );
        love.graphics.setColor( 255, 255, 255 );
        love.graphics.rectangle( 'line', x, y, love.graphics.getWidth() - x * 2, love.graphics.getHeight() - y * 2 );

        love.graphics.print( '-- Clothing:', x + TEXT_PADDING, y + TEXT_PADDING );

        local count = 0;
        for _, slot in pairs( CharacterManager.getCurrentCharacter():getInventory():getClothing() ) do
            count = count + 1;
            love.graphics.print( slot:getItem() and slot:getItem():getName() or 'Empty', x + TEXT_PADDING, y + TEXT_PADDING + count * 20 );
        end

        love.graphics.print( '-- Weapon:', x + TEXT_PADDING, y + 3 * TEXT_PADDING + count * TEXT_PADDING);
        love.graphics.print( CharacterManager.getCurrentCharacter():getInventory():getPrimaryWeapon():getName(), x + TEXT_PADDING, y + 4 * TEXT_PADDING + count * TEXT_PADDING);

        love.graphics.print( '-- Backpack:', x + TEXT_PADDING, y + 6 * TEXT_PADDING + count * TEXT_PADDING);
        love.graphics.print( CharacterManager.getCurrentCharacter():getInventory():getBackpack():getName(), x + TEXT_PADDING, y + 7 * TEXT_PADDING + count * TEXT_PADDING);
    end

    function self:keypressed( key )
        if key == 'escape' or key == 'i' then
            ScreenManager.pop();
        end
    end

    return self;
end

return InventoryScreen;
