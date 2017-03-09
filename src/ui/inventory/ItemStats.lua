local Object = require( 'src.Object' );
local Translator = require( 'src.util.Translator' );

local ItemStats = {};

local ITEM_TYPES = require('src.constants.ItemTypes');
local TILE_SIZE = require( 'src.constants.TileSize' );
local WEAPON_TYPES = require( 'src.constants.WeaponTypes' );

function ItemStats.new( x, y, w, h )
    local self = Object.new():addInstance( 'ItemStats' );

    local item;

    local function drawContainerStats()
        local volumeLimit = item:getCarryCapacity();
        love.graphics.print( 'Volume Limit: ' .. volumeLimit, x * TILE_SIZE, (y + 4) * TILE_SIZE );
    end

    local function drawWeaponStats()
        local weaponType = item:getSubType();
        love.graphics.print( 'Weapon Type: ' .. weaponType, x * TILE_SIZE, (y + 2) * TILE_SIZE );
        if weaponType == WEAPON_TYPES.RANGED then
            love.graphics.print( 'Ammo: ' .. item:getMagazine():getCaliber(), (x + w * 0.5) * TILE_SIZE, (y + 2) * TILE_SIZE );
        end

        for i = 1, #item:getModes() do
            local mode = item:getModes()[i];
            love.graphics.print( mode.name,                 x      * TILE_SIZE, ( y + 3 + i ) * TILE_SIZE );
            love.graphics.print( 'AP ' .. mode.cost,      ( x+10 ) * TILE_SIZE, ( y + 3 + i ) * TILE_SIZE );
            if not ( weaponType == WEAPON_TYPES.THROWN ) then
                love.graphics.print( 'ACC ' .. mode.accuracy, ( x+15 ) * TILE_SIZE, ( y + 3 + i ) * TILE_SIZE );
                love.graphics.print( 'ATT ' .. mode.attacks,  ( x+20 ) * TILE_SIZE, ( y + 3 + i ) * TILE_SIZE );
            end
        end
    end

    function self:draw()
        love.graphics.setScissor( x * TILE_SIZE, y * TILE_SIZE, w * TILE_SIZE, h * TILE_SIZE );

        if item then
            love.graphics.print( 'Name: ' .. Translator.getText( item:getID() ), x * TILE_SIZE, y * TILE_SIZE );
            love.graphics.print( 'Type: ' .. item:getItemType(), x * TILE_SIZE, (y + 1) * TILE_SIZE );
            love.graphics.print( 'WGT: ' .. string.format( '%.1f', item:getWeight() ), (x + w * 0.5) * TILE_SIZE, (y + 1) * TILE_SIZE );
            love.graphics.print( 'VOL: ' .. string.format( '%.1f', item:getVolume() ), (x + 5 + w * 0.5) * TILE_SIZE, (y + 1) * TILE_SIZE );

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
