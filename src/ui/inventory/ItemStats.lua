local Object = require( 'src.Object' );
local Translator = require( 'src.util.Translator' );
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

local ItemStats = {};

local ITEM_TYPES = require('src.constants.ITEM_TYPES')
local WEAPON_TYPES = require( 'src.constants.WeaponTypes' );

function ItemStats.new( x, y, w, h )
    local self = Object.new():addInstance( 'ItemStats' );

    local item;
    local tw, th = TexturePacks.getTileDimensions()

    local function drawContainerStats()
        local volumeLimit = item:getCarryCapacity();
        love.graphics.print( 'Volume Limit: ' .. volumeLimit, x * tw, (y + 4) * th )
    end

    local function drawWeaponStats()
        local weaponType = item:getSubType();
        love.graphics.print( 'Weapon Type: ' .. weaponType, x * tw, (y + 2) * th )
        if weaponType == WEAPON_TYPES.RANGED then
            love.graphics.print( 'Ammo: ' .. item:getMagazine():getCaliber(), (x + w * 0.5) * tw, (y + 2) * th )
        end

        for i = 1, #item:getModes() do
            local mode = item:getModes()[i];
            love.graphics.print( mode.name,                 x      * tw, ( y + 3 + i ) * th )
            love.graphics.print( 'AP ' .. mode.cost,      ( x+10 ) * tw, ( y + 3 + i ) * th )
            if not ( weaponType == WEAPON_TYPES.THROWN ) then
                love.graphics.print( 'ACC ' .. mode.accuracy, ( x+15 ) * tw, ( y + 3 + i ) * th )
                love.graphics.print( 'ATT ' .. mode.attacks,  ( x+20 ) * tw, ( y + 3 + i ) * th )
            end
        end
    end

    function self:draw()
        love.graphics.setScissor( x * tw, y * th, w * tw, h * th )

        if item then
            love.graphics.print( 'Name: ' .. Translator.getText( item:getID() ), x * tw, y * th )
            love.graphics.print( 'Type: ' .. item:getItemType(), x * tw, (y + 1) * th )
            love.graphics.print( 'WGT: ' .. string.format( '%.1f', item:getWeight() ), (x + w * 0.5) * tw, (y + 1) * th )
            love.graphics.print( 'VOL: ' .. string.format( '%.1f', item:getVolume() ), (x + 5 + w * 0.5) * tw, (y + 1) * th )

            if item:getItemType() == ITEM_TYPES.CONTAINER then
                drawContainerStats();
            elseif item:getItemType() == ITEM_TYPES.WEAPON then
                drawWeaponStats();
            end
        end

        love.graphics.setScissor();
    end

    function self:setItem( nitem )
        if nitem:instanceOf( 'ItemStack' ) then
            item = nitem:getItem();
            return;
        end

        item = nitem;
    end

    return self;
end

return ItemStats;
