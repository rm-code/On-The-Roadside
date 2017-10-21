local ScreenManager = require( 'lib.screenmanager.ScreenManager' );
local Screen = require( 'lib.screenmanager.Screen' );
local UIInventoryList = require( 'src.ui.inventory.UIInventoryList' );
local UIEquipmentList = require( 'src.ui.inventory.UIEquipmentList' );
local ScrollArea = require( 'src.ui.inventory.ScrollArea' );
local ItemStats = require( 'src.ui.inventory.ItemStats' );
local Translator = require( 'src.util.Translator' );
local Outlines = require( 'src.ui.elements.Outlines' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local InventoryScreen = {};

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
    local itemDescriptionSpacer; -- Spacers.
    local tw, th

    local itemDescriptionArea;
    local itemStatsArea;

    local outlines

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    local function getColumnWidth()
        return ( sx - 1 ) * tw
    end

    local function getEquipmentColumnOffset()
        return tw
    end

    local function getOtherColumnOffset()
        return ( 2 + 2 * sx ) * tw
    end

    local function getInventoryColumnOffset()
        return ( 2 + sx ) * tw
    end

    local function getListBelowCursor()
        for _, list in pairs( lists ) do
            if list:isMouseOver() then
                return list;
            end
        end
        return false;
    end

    local function createEquipment()
        lists.equipment = UIEquipmentList.new( getEquipmentColumnOffset(), 3 * th, sx * tw, 'inventory_equipment', character )
        lists.equipment:init();
    end

    local function createInventory()
        lists.inventory = UIInventoryList.new( getInventoryColumnOffset(), 3 * th, getColumnWidth(), 'inventory_inventory', character:getInventory() )
        lists.inventory:init();
    end

    local function createOtherInventory()
        local x, y, cw = getOtherColumnOffset(), 3 * th, getColumnWidth()

        if target:instanceOf( 'Inventory' ) then
            lists.other = UIInventoryList.new( x, y, cw, 'inventory_base', target )
            lists.other:init()
            return
        end

        -- Create inventory for container world objects.
        if target:hasWorldObject() and target:getWorldObject():isContainer() then
            lists.other = UIInventoryList.new( x, y, cw, 'inventory_container_inventory', target:getWorldObject():getInventory() );
            lists.other:init();
            return;
        end

        -- Create inventory for other characters of the same faction.
        if target:isOccupied() and target:getCharacter() ~= character and target:getCharacter():getFaction():getType() == character:getFaction():getType() then
            lists.other = UIInventoryList.new( x, y, cw, 'inventory_inventory', target:getCharacter():getInventory() );
            lists.other:init();
            return;
        end

        -- Create inventory for a tile's floor.
        lists.other = UIInventoryList.new( x, y, cw, 'inventory_tile_inventory', target:getInventory() );
        lists.other:init();
    end

    local function returnItemToOrigin( item, origin )
        if origin:instanceOf( 'EquipmentSlot' ) then
            character:getEquipment():addItem( origin, item )
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
            if item:instanceOf( 'Container' ) then
                createInventory();
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
        dragboard = nil;
    end

    local function drawHeaders()
        love.graphics.print( lists.equipment:getLabel(), getEquipmentColumnOffset(), th )

        if lists.inventory then
            love.graphics.print( lists.inventory:getLabel(), getInventoryColumnOffset(), th )
        else
            love.graphics.print( 'No inventory equipped', getInventoryColumnOffset(), th )
        end

        love.graphics.print( lists.other:getLabel(), getOtherColumnOffset(), th )

        love.graphics.print( 'Item Description', getEquipmentColumnOffset(), ( 1 + 2 * sy ) * th )
        love.graphics.print( 'Item Attributes',  ( itemDescriptionSpacer + 1 ) * tw, ( 1 + 2 * sy ) * th )
    end

    local function updateScreenDimensions( nw, nh )
        w  = math.floor( nw / tw )
        h  = math.floor( nh / th )
        sx = math.floor( w / 3 );
        sy = math.floor( h / 3 );
        itemDescriptionSpacer = math.floor( w / 2 );
    end

    local function createOutlines()
        for x = 0, w - 1 do
            for y = 0, h - 1 do
                -- Draw borders.
                if x == 0 or x == (w - 1) or y == 0 or y == (h - 1) then
                    outlines:add( x, y )
                end

                -- Draw vertical column lines.
                if ( x == 1 + sx or x == 1 + 2 * sx ) and ( y < 2 * sy ) then
                    outlines:add( x, y )
                end

                -- Draw bottom line of the column headers.
                if y == 2 then
                    outlines:add( x, y )
                end

                -- Draw the horizontal line below the inventory columns.
                if y == 2 * sy then
                    outlines:add( x, y )
                end

                -- Draw item description separator.
                if x == itemDescriptionSpacer and y > 2 * sy then
                    outlines:add( x, y )
                end

                -- Draw horizontal line for item stats and description.
                if y == ( 2 * sy + 2 ) then
                    outlines:add( x, y )
                end
            end
        end
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    ---
    -- Creates the three inventory lists for the player's equipment, his inventory
    -- and the tile he is standing on.
    -- @param ncharacter (Character) The character to open the inventory for.
    -- @param ntarget    (Tile)      The target tile to open the inventory for.
    --
    function self:init( ncharacter, ntarget )
        tw, th = TexturePacks.getTileDimensions()

        character = ncharacter;
        target = ntarget;

        love.mouse.setVisible( true );
        updateScreenDimensions( love.graphics.getDimensions() );

        outlines = Outlines.new();
        createOutlines()
        outlines:refresh()

        itemDescriptionArea = ScrollArea.new( 1, 3 + 2 * sy, itemDescriptionSpacer - 1, sy - 3 );
        itemStatsArea = ItemStats.new( itemDescriptionSpacer + 1, 3 + 2 * sy, itemDescriptionSpacer - 2, sy - 3 );

        lists = {};

        createEquipment();
        createInventory();
        createOtherInventory();
    end

    ---
    -- Draws the inventory lists and the dragged item (if there is one).
    --
    function self:draw()
        TexturePacks.setColor( 'sys_background' )
        love.graphics.rectangle( 'fill', 0, 0, love.graphics.getDimensions() );
        TexturePacks.resetColor()

        outlines:draw( 0, 0 )
        drawHeaders( love.graphics.getWidth() );

        for _, list in pairs( lists ) do
            list:draw();
            if list:isMouseOver() then
                local item = list:getItemBelowCursor();
                if item then
                    itemDescriptionArea:setText( Translator.getText( item:getDescriptionID() ));
                    itemDescriptionArea:draw();

                    itemStatsArea:setItem( item );
                end
            end
        end

        if dragboard then
            local mx, my = love.mouse.getPosition();

            TexturePacks.setColor( 'ui_inventory_item' )
            for _, list in pairs( lists ) do
                if list:isMouseOver() then
                    local di = dragboard.item;
                    if not list:doesFit( di ) then
                        TexturePacks.setColor( 'ui_inventory_full' )
                        break;
                    end
                end
            end

            local item = dragboard.item;
            local str = item and Translator.getText( item:getID() ) or Translator.getText( 'inventory_empty_slot' );
            if item:instanceOf( 'ItemStack' ) and item:getItemCount() > 1 then
                str = string.format( '%s (%d)', str, item:getItemCount() );
            end
            love.graphics.print( str, mx, my );
            TexturePacks.setColor( 'ui_text' )

            itemDescriptionArea:setText( Translator.getText( item:getDescriptionID() ));
            itemDescriptionArea:draw();

        end

        lists.equipment:highlightSlot( dragboard and dragboard.item );
        itemStatsArea:draw();
    end

    ---
    -- Updates the inventory lists.
    --
    function self:update( dt )
        if target:instanceOf( 'Tile' ) then
            target:setDirty( true )
        end

        for _, list in pairs( lists ) do
            list:update( dt );
        end
    end

    function self:keypressed( key )
        if key == 'up' then
            itemDescriptionArea:scrollVertically( 1 );
        elseif key == 'down' then
            itemDescriptionArea:scrollVertically( -1 );
        elseif key == 'escape' or key == 'i' then
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

    function self:resize()
        self:init( character, target );
    end

    function self:close()
        love.mouse.setVisible( false );

        -- Drop any item that is currently dragged.
        if dragboard then
            drop();
        end
    end

    return self;
end

return InventoryScreen;
