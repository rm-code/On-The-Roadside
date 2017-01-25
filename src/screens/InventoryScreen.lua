local ScreenManager = require( 'lib.screenmanager.ScreenManager' );
local Screen = require( 'lib.screenmanager.Screen' );
local UIInventoryList = require( 'src.ui.inventory.UIInventoryList' );
local UIEquipmentList = require( 'src.ui.inventory.UIEquipmentList' );
local Translator = require( 'src.util.Translator' );
local Tileset = require( 'src.ui.Tileset' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local InventoryScreen = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local COLORS = require( 'src.constants.Colors' );
local TILE_SIZE = require( 'src.constants.TileSize' );

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function InventoryScreen.new()
    local self = Screen.new();

    local character;
    local lists;
    local dragboard;
    local target;

    local  w,  h;
    local sx, sy; -- Spacers.

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    local function refreshBackpack()
        if character:getBackpack() then
            lists.backpack = UIInventoryList.new(( 2 + sx ) * TILE_SIZE, 3 * TILE_SIZE, ( sx - 1 ) * TILE_SIZE, 'inventory_backpack', character:getBackpack():getInventory() );
            lists.backpack:init();
        else
            lists.backpack = nil;
        end
    end

    local function drawOutlines()
        local ts = Tileset.getTileset();

        love.graphics.setColor( COLORS.DB22 );

        -- Draw horizontal lines.
        for x = 1, w - 2 do
            love.graphics.draw( ts, Tileset.getSprite( 197 ), x * TILE_SIZE,                          0 );
            love.graphics.draw( ts, Tileset.getSprite( 197 ), x * TILE_SIZE,            2   * TILE_SIZE );
            love.graphics.draw( ts, Tileset.getSprite( 197 ), x * TILE_SIZE,      ( h - 1 ) * TILE_SIZE );
            love.graphics.draw( ts, Tileset.getSprite( 197 ), x * TILE_SIZE, ( 1 + 2 * sy ) * TILE_SIZE );
        end

        -- Draw vertical lines.
        for y = 1, h - 2 do
            love.graphics.draw( ts, Tileset.getSprite( 180 ),                     0, y * TILE_SIZE ); -- Left
            love.graphics.draw( ts, Tileset.getSprite( 180 ), ( w - 1 ) * TILE_SIZE, y * TILE_SIZE ); -- Right

            if y < ( 1 + 2 * sy ) then
                love.graphics.draw( ts, Tileset.getSprite( 180 ), ( 1 +     sx ) * TILE_SIZE, y * TILE_SIZE );
                love.graphics.draw( ts, Tileset.getSprite( 180 ), ( 1 + 2 * sx ) * TILE_SIZE, y * TILE_SIZE );
            end
        end

        -- Draw vertical line connectors.
        love.graphics.draw( ts, Tileset.getSprite( 195 ), ( 1 +     sx ) * TILE_SIZE,                     0 );
        love.graphics.draw( ts, Tileset.getSprite( 195 ), ( 1 + 2 * sx ) * TILE_SIZE,                     0 );

        -- Draw horizontal line connectors.
        love.graphics.draw( ts, Tileset.getSprite( 196 ),                          0, 2 * TILE_SIZE ); -- Headline left
        love.graphics.draw( ts, Tileset.getSprite( 181 ), ( w - 1      ) * TILE_SIZE, 2 * TILE_SIZE ); -- Headline 1st column
        love.graphics.draw( ts, Tileset.getSprite( 198 ), ( 1 +     sx ) * TILE_SIZE, 2 * TILE_SIZE ); -- Headline 2nd column
        love.graphics.draw( ts, Tileset.getSprite( 198 ), ( 1 + 2 * sx ) * TILE_SIZE, 2 * TILE_SIZE ); -- Headline right

        love.graphics.draw( ts, Tileset.getSprite( 196 ),                          0, ( 1 + 2 * sy ) * TILE_SIZE ); -- Item description left
        love.graphics.draw( ts, Tileset.getSprite( 181 ), ( w - 1      ) * TILE_SIZE, ( 1 + 2 * sy ) * TILE_SIZE ); -- Item description 1st column
        love.graphics.draw( ts, Tileset.getSprite( 194 ), ( 1 +     sx ) * TILE_SIZE, ( 1 + 2 * sy ) * TILE_SIZE ); -- Item description 2nd column
        love.graphics.draw( ts, Tileset.getSprite( 194 ), ( 1 + 2 * sx ) * TILE_SIZE, ( 1 + 2 * sy ) * TILE_SIZE ); -- Item description right

        -- Draw corners.
        love.graphics.draw( ts, Tileset.getSprite( 192 ), ( w - 1 ) * TILE_SIZE,                     0 );
        love.graphics.draw( ts, Tileset.getSprite( 218 ), ( w - 1 ) * TILE_SIZE, ( h - 1 ) * TILE_SIZE );
        love.graphics.draw( ts, Tileset.getSprite( 219 ),                     0,                     0 );
        love.graphics.draw( ts, Tileset.getSprite( 193 ),                     0, ( h - 1 ) * TILE_SIZE );
    end

    local function drawHeaders()
        love.graphics.print( lists.equipment:getLabel(), TILE_SIZE, TILE_SIZE );

        if lists.backpack then
            love.graphics.print( lists.backpack:getLabel(), ( 2 + sx ) * TILE_SIZE, TILE_SIZE );
        else
            love.graphics.print( 'No backpack equipped', ( 2 + sx ) * TILE_SIZE, TILE_SIZE );
        end

        love.graphics.print( lists.other:getLabel(), ( 2 + 2 * sx ) * TILE_SIZE, TILE_SIZE );
    end

    local function getListBelowCursor()
        for _, list in pairs( lists ) do
            if list:isMouseOver() then
                return list;
            end
        end
        return false;
    end

    local function returnItemToOrigin( item, origin )
        if origin:instanceOf( 'EquipmentSlot' ) then
            origin:addItem( item );
        else
            origin:drop( item );
        end
    end

    local function drag( list, button )
        if not list then
            return;
        end

        local item, slot = list:drag( button == 2, love.keyboard.isDown( 'lshift' ));
        if item then
            -- If we have an actual item slot we use it as the origin to
            -- which the item is returned in case it can't be dropped anywhere.
            dragboard = { item = item, origin = slot or list };
            if item:instanceOf( 'Bag' ) then
                refreshBackpack();
            end
        end
    end

    local function drop( list )
        if not list then
            returnItemToOrigin( dragboard.item, dragboard.origin );
        else
            local success = list:drop( dragboard.item, dragboard.origin );
            if not success then
                returnItemToOrigin( dragboard.item, dragboard.origin );
            end
        end
        refreshBackpack();
        dragboard = nil;
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    ---
    -- Creates the three inventory lists for the player's equipment, his Backpack
    -- and the tile he is standing on.
    -- @param ncharacter (Character) The character to open the inventory for.
    -- @param ntarget    (Tile)      The target tile to open the inventory for.
    --
    function self:init( ncharacter, ntarget )
        character = ncharacter;
        target = ntarget;

        love.mouse.setVisible( true );

        w  = math.floor( love.graphics.getWidth()  / TILE_SIZE );
        h  = math.floor( love.graphics.getHeight() / TILE_SIZE );
        sx = math.floor( w / 3 );
        sy = math.floor( h / 3 );

        lists = {};

        lists.equipment = UIEquipmentList.new( TILE_SIZE, 3 * TILE_SIZE, sx * TILE_SIZE, 'inventory_equipment', character );
        lists.equipment:init();

        if character:getBackpack() then
            lists.backpack = UIInventoryList.new(( 2 + sx ) * TILE_SIZE, 3 * TILE_SIZE, ( sx - 1 ) * TILE_SIZE, 'inventory_backpack', character:getBackpack():getInventory() );
            lists.backpack:init();
        end

        -- Create a list for the tile inventory or a container located on the tile.
        if target:hasWorldObject() and target:getWorldObject():isContainer() then
            lists.other = UIInventoryList.new(( 2 + 2 * sx ) * TILE_SIZE, 3 * TILE_SIZE, ( sx - 1 ) * TILE_SIZE, 'inventory_container_inventory', target:getWorldObject():getInventory() );
            lists.other:init();
        elseif target:isOccupied() and target:getCharacter() ~= character and target:getCharacter():getFaction():getType() == character:getFaction():getType() then
            lists.other = UIInventoryList.new( 620, 20, ( sx - 1 ) * TILE_SIZE, 'inventory_backpack', target:getCharacter():getBackpack():getInventory() );
            lists.other:init();
        else
            lists.other = UIInventoryList.new(( 2 + 2 * sx ) * TILE_SIZE, 3 * TILE_SIZE, ( sx - 1 ) * TILE_SIZE, 'inventory_tile_inventory', target:getInventory() );
            lists.other:init();
        end
    end

    ---
    -- Draws the inventory lists and the dragged item (if there is one).
    --
    function self:draw()
        -- Draw a transparent overlay.
        love.graphics.setColor( 0, 0, 0, 220 );
        love.graphics.rectangle( 'fill', 0, 0, love.graphics.getDimensions() );
        love.graphics.setColor( 255, 255, 255, 255 );

        drawOutlines( love.graphics.getDimensions() );
        drawHeaders( love.graphics.getWidth() );

        for _, list in pairs( lists ) do
            list:draw();
        end

        if dragboard then
            local mx, my = love.mouse.getPosition();
            love.graphics.setColor( COLORS.DB20 );

            local item = dragboard.item;
            local str = item and Translator.getText( item:getID() ) or Translator.getText( 'inventory_empty_slot' );
            if item:instanceOf( 'ItemStack' ) and item:getItemCount() > 1 then
                str = string.format( '%s (%d)', str, item:getItemCount() );
            end
            love.graphics.print( str, mx, my );

        end

        lists.equipment:highlightSlot( dragboard and dragboard.item );
    end

    ---
    -- Updates the inventory lists.
    --
    function self:update( dt )
        for _, list in pairs( lists ) do
            list:update( dt );
        end
    end

    function self:keypressed( key )
        if key == 'escape' or key == 'i' then
            ScreenManager.pop();
        end
    end

    function self:mousepressed( _, _, button )
        if dragboard then
            return;
        end

        local list = getListBelowCursor();
        drag( list, button );
    end

    function self:mousereleased( _, _, _ )
        if not dragboard then
            return;
        end

        local list = getListBelowCursor();
        drop( list );
    end

    function self:close()
        love.mouse.setVisible( false );
        drop(); -- Drop any item that is currently dragged.
    end

    return self;
end

return InventoryScreen;
