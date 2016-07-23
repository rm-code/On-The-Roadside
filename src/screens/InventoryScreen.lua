local ScreenManager = require( 'lib.screenmanager.ScreenManager' );
local Screen = require( 'lib.screenmanager.Screen' );
local FactionManager = require( 'src.characters.FactionManager' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local InventoryScreen = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local COLORS = require( 'src.constants.Colors' );
local ITEM_TYPES = require( 'src.constants.ItemTypes' );

local SCREEN_PADDING = 20;
local TEXT_PADDING = 20;

local SECOND_COLUMN = 200;

local THIRD_COLUMN = 400;

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function InventoryScreen.new()
    local self = Screen.new();

    local character = FactionManager.getCurrentCharacter();
    local rowIndex    = 1;
    local columnIndex = 1;

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    local function unequipItem()
        for i, slot in ipairs( character:getStorage():getSlots() ) do
            if i == rowIndex then
                local item = slot:getItem();
                slot:removeItem();

                if slot:getItemType() == ITEM_TYPES.BAG or not character:getBackpack() then
                    character:getTile():getStorage():addItem( item );
                    break;
                else
                    character:getBackpack():getStorage():addItem( item );
                    break;
                end
            end
        end
    end

    local function equipItem()
        for i, slot in ipairs( character:getBackpack():getStorage():getSlots() ) do
            if i == rowIndex then
                local item = slot:getItem();
                if not item then
                    return;
                end

                slot:removeItem();
                character:getStorage():addItem( item );
                return;
            end
        end
    end

    local function dropItem()
        for i, slot in ipairs( character:getBackpack():getStorage():getSlots() ) do
            if i == rowIndex then
                local item = slot:getItem();
                slot:removeItem();

                character:getTile():getStorage():addItem( item );
                break;
            end
        end
    end

    local function grabItem()
        for i, slot in ipairs( character:getTile():getStorage():getSlots() ) do
            if i == rowIndex then
                local item = slot:getItem();
                slot:removeItem();

                if not character:getBackpack() then
                    character:getStorage():addItem( item );
                else
                    character:getBackpack():getStorage():addItem( item );
                end
                break;
            end
        end
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:draw()
        local x = SCREEN_PADDING;
        local y = SCREEN_PADDING;

        love.graphics.setColor( COLORS.DB00 );
        love.graphics.rectangle( 'fill', x, y, love.graphics.getWidth() - x * 2, love.graphics.getHeight() - y * 2 );
        love.graphics.setColor( COLORS.DB21 );
        love.graphics.rectangle( 'line', x, y, love.graphics.getWidth() - x * 2, love.graphics.getHeight() - y * 2 );

        love.graphics.print( '-- Equipment:', x + TEXT_PADDING, y + TEXT_PADDING );

        for i, slot in ipairs( character:getStorage():getSlots() ) do
            if i == rowIndex and columnIndex == 1 then
                love.graphics.setColor( COLORS.DB26 );
            end
            love.graphics.print( slot:getItem() and slot:getItem():getName() or 'Empty', x + TEXT_PADDING, y + TEXT_PADDING + i * 20 );
            love.graphics.setColor( COLORS.DB21 );
        end

        x = SECOND_COLUMN;

        love.graphics.print( '-- Backpack:', x + TEXT_PADDING, y + TEXT_PADDING );

        if character:getBackpack() ~= nil then
            for i, slot in ipairs( character:getBackpack():getStorage():getSlots() ) do
                if i == rowIndex and columnIndex == 2 then
                    love.graphics.setColor( COLORS.DB26 );
                end
                love.graphics.print( slot:getItem() and slot:getItem():getName() or 'Empty', x + TEXT_PADDING, y + TEXT_PADDING + i * 20 );
                love.graphics.setColor( COLORS.DB21 );
            end
        end

        x = THIRD_COLUMN;

        love.graphics.print( '-- Ground:', x + TEXT_PADDING, y + TEXT_PADDING );

        for i, slot in ipairs( character:getTile():getStorage():getSlots() ) do
            if i == rowIndex and columnIndex == 3 then
                love.graphics.setColor( COLORS.DB26 );
            end
            love.graphics.print( slot:getItem() and slot:getItem():getName() or 'Empty', x + TEXT_PADDING, y + TEXT_PADDING + i * 20 );
            love.graphics.setColor( COLORS.DB21 );
        end
    end

    function self:keypressed( key )
        if key == 'escape' or key == 'i' then
            ScreenManager.pop();
        end

        if key == 'up' then
            local limit;
            if columnIndex == 1 then
                limit = #character:getStorage():getSlots();
            elseif columnIndex == 2 then
                limit = #character:getBackpack():getStorage():getSlots();
            elseif columnIndex == 3 then
                limit = #character:getTile():getStorage():getSlots();
            end

            rowIndex = rowIndex - 1 < 1 and limit or rowIndex - 1;
        elseif key == 'down' then
            local limit;
            if columnIndex == 1 then
                limit = #character:getStorage():getSlots();
            elseif columnIndex == 2 then
                limit = #character:getBackpack():getStorage():getSlots();
            elseif columnIndex == 3 then
                limit = #character:getTile():getStorage():getSlots();
            end

            rowIndex = rowIndex + 1 > limit and 1 or rowIndex + 1;
        elseif key == 'right' then
            rowIndex = 1;

            columnIndex = columnIndex + 1 > 3 and 1 or columnIndex + 1;

            if not character:getBackpack() and columnIndex == 2 then
                columnIndex = 3;
            end
        elseif key == 'left' then
            rowIndex = 1;
            columnIndex = columnIndex - 1 < 1 and 3 or columnIndex - 1;

            if not character:getBackpack() and columnIndex == 2 then
                columnIndex = 1;
            end
        end

        if key == 'backspace' and columnIndex == 1 then
            unequipItem();
        elseif key == 'backspace' and columnIndex == 2 then
            dropItem();
        elseif key == 'return' and columnIndex == 2 then
            equipItem();
        elseif key == 'return' and columnIndex == 3 then
            grabItem();
        end
    end

    return self;
end

return InventoryScreen;
