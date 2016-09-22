local ScreenManager = require( 'lib.screenmanager.ScreenManager' );
local Screen = require( 'lib.screenmanager.Screen' );
local UIInventoryList = require( 'src.ui.inventory.UIInventoryList' );
local UIEquipmentList = require( 'src.ui.inventory.UIEquipmentList' );
local Translator = require( 'src.util.Translator' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local InventoryScreen = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local COLORS = require( 'src.constants.Colors' );
local DRAGGED_ITEM_WIDTH  = 150;
local DRAGGED_ITEM_HEIGHT =  30;

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function InventoryScreen.new()
    local self = Screen.new();

    local character;
    local lists;
    local dragboard;
    local target;

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    local function refreshBackpack()
        if character:getInventory():getBackpack() then
            lists.backpack = UIInventoryList.new( 220, 20, 'inventory_backpack', character:getInventory():getBackpack():getInventory() );
            lists.backpack:init();
        else
            lists.backpack = nil;
        end
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

        lists = {};

        lists.equipment = UIEquipmentList.new( 20, 20, 'inventory_equipment', character:getInventory() );
        lists.equipment:init();

        if character:getInventory():getBackpack() then
            lists.backpack = UIInventoryList.new( 220, 20, 'inventory_backpack', character:getInventory():getBackpack():getInventory() );
            lists.backpack:init();
        end

        -- Create a list for the tile inventory or a container located on the tile.
        if target:hasWorldObject() and target:getWorldObject():isContainer() then
            lists.container = UIInventoryList.new( 420, 20, 'inventory_container_inventory', target:getWorldObject():getInventory() );
            lists.container:init();
        elseif target:isOccupied() and target:getCharacter():getFaction():getType() == character:getFaction():getType() then
            lists.oequipment = UIEquipmentList.new( 420, 20, 'inventory_equipment', target:getCharacter():getInventory() );
            lists.oequipment:init();
            lists.obackpack = UIInventoryList.new( 620, 20, 'inventory_backpack', target:getCharacter():getInventory():getBackpack():getInventory() );
            lists.obackpack:init();
        else
            lists.ground = UIInventoryList.new( 420, 20, 'inventory_tile_inventory', target:getInventory() );
            lists.ground:init();
        end
    end

    ---
    -- Draws the inventory lists and the dragged item (if there is one).
    --
    function self:draw()
        -- Draw a transparent overlay.
        love.graphics.setColor( 0, 0, 0, 200 );
        love.graphics.rectangle( 'fill', 0, 0, love.graphics.getDimensions() );
        love.graphics.setColor( 255, 255, 255, 255 );

        for _, list in pairs( lists ) do
            list:draw();
        end

        if dragboard then
            local mx, my = love.mouse.getPosition();
            love.graphics.setColor( COLORS.DB00 );
            love.graphics.rectangle( 'fill', mx, my, DRAGGED_ITEM_WIDTH, DRAGGED_ITEM_HEIGHT );
            love.graphics.setColor( COLORS.DB23 );
            love.graphics.rectangle( 'line', mx, my, DRAGGED_ITEM_WIDTH, DRAGGED_ITEM_HEIGHT );
            love.graphics.setColor( COLORS.DB21 );

            local item = dragboard.item;
            local str = item and Translator.getText( item:getID() ) or Translator.getText( 'inventory_empty_slot' );
            if item:instanceOf( 'ItemStack' ) and item:getItemCount() > 1 then
                str = string.format( '%s (%d)', str, item:getItemCount() );
            end
            love.graphics.printf( str, mx, my + 5, DRAGGED_ITEM_WIDTH, 'center' );
        end
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
        for _, list in pairs( lists ) do
            if list:isMouseOver() then
                if dragboard then
                    local success = list:drop( dragboard.item, dragboard.origin );
                    if success then
                        if dragboard.item:instanceOf( 'Bag' ) then
                            refreshBackpack();
                        end
                        dragboard = nil;
                    else
                        dragboard.origin:drop( dragboard.item );
                        dragboard = nil;
                    end
                else
                    local item = list:drag( button == 2, love.keyboard.isDown( 'lshift' ));
                    if item then
                        dragboard = { item = item, origin = list };
                        if item:instanceOf( 'Bag' ) then
                            refreshBackpack();
                        end
                    end
                end
            end
        end
    end

    function self:close()
        love.mouse.setVisible( false );
    end

    return self;
end

return InventoryScreen;
