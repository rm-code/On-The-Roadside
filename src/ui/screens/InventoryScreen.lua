---
-- @module InventoryScreen
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Screen = require( 'lib.screenmanager.Screen' )
local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local UIOutlines = require( 'src.ui.elements.UIOutlines' )
local UIBackground = require( 'src.ui.elements.UIBackground' )
local UIEquipmentList = require( 'src.ui.elements.inventory.UIEquipmentList' )
local UIInventoryList = require( 'src.ui.elements.inventory.UIInventoryList' )
local UITranslatedLabel = require( 'src.ui.elements.UITranslatedLabel' )
local UIInventoryDragboard = require( 'src.ui.elements.inventory.UIInventoryDragboard' )
local UIItemStats = require( 'src.ui.elements.inventory.UIItemStats' )
local GridHelper = require( 'src.util.GridHelper' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local InventoryScreen = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

-- The dimensions of the whole inventory screen.
local UI_GRID_WIDTH  = 64
local UI_GRID_HEIGHT = 48

-- The width and height of the inventory columns.
local COLUMN_WIDTH = 20
local COLUMN_HEIGHT = 44

-- The width and hight of the item equipment column.
local EQUIPMENT_WIDTH = COLUMN_WIDTH
local EQUIPMENT_HEIGHT = 12

-- The width and hight of the item stats column.
local ITEM_STATS_WIDTH = COLUMN_WIDTH
local ITEM_STATS_HEIGHT = COLUMN_HEIGHT - EQUIPMENT_HEIGHT - 1

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function InventoryScreen.new()
    local self = Screen.new()

    local x, y

    local outlines
    local background

    local lists
    local listLabels

    local itemStats

    local dragboard

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    ---
    -- Creates the outlines for the Inventory window.
    --
    local function generateOutlines()
        outlines = UIOutlines.new( x, y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )

        -- Horizontal borders.
        for ox = 0, UI_GRID_WIDTH-1 do
            outlines:add( ox, 0                ) -- Top
            outlines:add( ox, UI_GRID_HEIGHT-1 ) -- Bottom
        end

        -- Horizontal line below Equipment list.
        -- Offset calculations:
        --  y-axis: Outline top + Header + Outline Header + EQUIPMENT_HEIGHT => EQUIPMENT_HEIGHT+3
        for ox = 0, COLUMN_WIDTH do
            outlines:add( ox, EQUIPMENT_HEIGHT+3 )
        end

        -- Vertical outlines.
        for oy = 0, UI_GRID_HEIGHT-1 do
            outlines:add( 0,               oy ) -- Left
            outlines:add( UI_GRID_WIDTH-1, oy ) -- Right
        end

        -- Vertical line after the equipment column.
        -- Offset calculations:
        --  x:axis: Outline left + First column => 1 + COLUMN_WIDTH
        for oy = 0, UI_GRID_HEIGHT-1 do
            outlines:add( 1+COLUMN_WIDTH, oy )
        end

        -- Vertical line after the inventory column.
        -- Offset calculations:
        --  x-axis: Outline left + First column + Outline + Second Column
        --      => 1 + COLUMN_WIDTH + 1 + COLUMN_WIDTH
        --      => 2 + 2*COLUMN_WIDTH
        for oy = 0, UI_GRID_HEIGHT-1 do
            outlines:add( 2 + 2*COLUMN_WIDTH, oy )
        end

        -- Horizontal line for column headers.
        -- Offset calculations:
        --  x-axis: Outline top + Header line => 2
        for ox = 0, UI_GRID_WIDTH-1 do
            outlines:add( ox, 2 )
        end

        outlines:refresh()
    end

    ---
    -- Creates the equipment list for the currently selected character and the
    -- associated header label.
    -- @tparam Character character The character to use for the equipment list.
    --
    local function createEquipmentList( character )
        -- Offset calculations:
        --  x-axis: Outline left => 1
        --  y-axis: Outline top + Header Text + Outline below Header => 3
        local ox, oy = 1, 3
        lists.equipment = UIEquipmentList.new( x, y, ox, oy, EQUIPMENT_WIDTH, EQUIPMENT_HEIGHT )
        lists.equipment:init( character )

        -- Offset calculations:
        --  x-axis: Outline left => 1
        --  y-axis: Outline top => 1
        local lx, ly = 1, 1
        listLabels.equipment = UITranslatedLabel.new( x, y, lx, ly, EQUIPMENT_WIDTH, 1, 'inventory_equipment', 'ui_inventory_headers' )
    end

    ---
    -- Creates the character's "backpack" inventory in which all items he carries
    -- are stored and the associated header label.
    -- @tparam Character character The character to use for the equipment list.
    --
    local function createCharacterInventoryList( character )
        -- Offset calculations:
        --  x-axis: Outline left + Equipment Column + Equipment Column Outline
        --      => 1 + COLUMN_WIDTH + 1
        --      => 2 + COLUMN_WIDTH
        --  y-axis: Outline top + Header Text + Outline below Header => 3
        local ox, oy = 2 + COLUMN_WIDTH, 3
        lists.characterInventory = UIInventoryList.new( x, y, ox, oy, COLUMN_WIDTH, COLUMN_HEIGHT )
        lists.characterInventory:init( character:getInventory() )

        -- Label coordinates relative to the screen's coordinates.
        --      x-axis: Outline left + Equipment Column + Equipment Column Outline
        --              => 1 + COLUMN_WIDTH + 1
        --              => 2 + COLUMN_WIDTH
        --      y-axis: Outline top => 1
        local lx, ly = 2 + COLUMN_WIDTH, 1
        listLabels.characterInventory = UITranslatedLabel.new( x, y, lx, ly, COLUMN_WIDTH, 1, 'inventory_character', 'ui_inventory_headers' )
    end

    ---
    -- Creates the target inventory with which the character wants to interact.
    -- and the associated header label.
    -- @tparam Character character The character to use for the equipment list.
    -- @tparam Tile      target    The target tile to interact with.
    --
    local function createTargetInventoryList( character, target )
        local id, inventory

        -- TODO How to handle base inventory?
        if target:instanceOf( 'Inventory' ) then
            id, inventory = 'inventory_base', target
        elseif target:hasWorldObject() and target:getWorldObject():isContainer() then
            id, inventory = 'inventory_container_inventory', target:getWorldObject():getInventory()
        elseif target:isOccupied() and target:getCharacter() ~= character and target:getCharacter():getFaction():getType() == character:getFaction():getType() then
            id, inventory = 'inventory_character', target:getCharacter():getInventory()
        else
            id, inventory = 'inventory_tile_inventory', target:getInventory()
        end

        -- Offset calculations:
        --  x-axis: Outline left + Equipment Column + Equipment Column Outline
        --          + Character Inventory Column + Character Inventory Column Outline
        --          => 1 + COLUMN_WIDTH + 1 + COLUMN_WIDTH + 1
        --          => 3 + 2 * COLUMN_WIDTH
        --  y-axis: Outline top + Header Text + Outline below Header => 3
        local ox, oy = 3 + 2 * COLUMN_WIDTH, 3
        lists.targetInventory = UIInventoryList.new( x, y, ox, oy, COLUMN_WIDTH, COLUMN_HEIGHT )
        lists.targetInventory:init( inventory )

        -- Offset calculations:
        --  x-axis: Outline left + Equipment Column + Equipment Column Outline
        --          + Character Inventory Column + Character Inventory Column Outline
        --          => 1 + COLUMN_WIDTH + 1 + COLUMN_WIDTH + 1
        --          => 3 + 2 * COLUMN_WIDTH
        --  y-axis: Outline top => 1
        local lx, ly = 3 + 2 * COLUMN_WIDTH, 1
        listLabels.targetInventory = UITranslatedLabel.new( x, y, lx, ly, COLUMN_WIDTH, 1, id, 'ui_inventory_headers' )
    end

    ---
    -- Creates the equipment and inventory lists.
    -- @tparam Character character The character to use for the equipment list.
    -- @tparam Tile      target    The target tile to interact with.
    --
    local function createInventoryLists( character, target )
        lists = {}
        listLabels = {}
        createEquipmentList( character )
        createCharacterInventoryList( character )
        createTargetInventoryList( character, target )
    end

    ---
    -- Returns the list the mouse is currently over.
    -- @return The equipment or inventory list the mouse is over.
    --
    local function getListBelowCursor()
        for _, list in pairs( lists ) do
            if list:isMouseOver() then
                return list
            end
        end
    end

    ---
    -- Refreshes all inventor lists.
    --
    local function refreshLists()
        for _, list in pairs( lists ) do
            list:refresh()
        end
    end

    ---
    -- Initiates a drag action.
    -- @tparam number button The mouse button index.
    --
    local function drag( button )
        -- Can't drag if we are already dragging.
        if dragboard:hasDragContext() then
            return
        end

        -- Can't drag if not over a list.
        local list = getListBelowCursor()
        if not list then
            return
        end

        local item, slot = list:drag( button == 2, love.keyboard.isDown( 'lshift' ))

        -- Abort if there is nothing to drag here.
        if not item then
            return
        end

        -- Display stats for the dragged item.
        itemStats:setItem( item )

        -- If we have an actual item slot we use it as the origin to
        -- which the item is returned in case it can't be dropped anywhere.
        dragboard:drag( item, slot or list )

        -- If the dragged item is a container we need to refresh the inventory lists
        -- because it changes the inventory volumes.
        if item:instanceOf( 'Container' ) then
            refreshLists()
        end
    end

    ---
    -- Selects an item for the item stats area.
    --
    local function selectItem()
        local list = getListBelowCursor()
        if not list then
            return
        end

        local item = list:getItemBelowCursor()
        if not item then
            return
        end

        itemStats:setItem( item )
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    ---
    -- Initialises the inventory screen.
    -- @tparam Character ncharacter The character to open the inventory for.
    -- @tparam Tile      ntarget    The target tile to open the inventory for.
    --
    function self:init( character, target )
        love.mouse.setVisible( true )

        x, y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )

        -- General UI Elements.
        background = UIBackground.new( x, y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )
        generateOutlines()

        -- UI inventory lists.
        createInventoryLists( character, target )

        dragboard = UIInventoryDragboard.new()

        -- Add the item stats area which displays the item attributes and a description area.
        --      x-axis: Outline left => 1
        --      y-axis: Outline top + Header + Outl ine Header
        --              + Outline below equipment + EQUIPMENT_HEIGHT
        --              => EQUIPMENT_HEIGHT+4
        itemStats = UIItemStats.new( x, y, 1, EQUIPMENT_HEIGHT+4, ITEM_STATS_WIDTH, ITEM_STATS_HEIGHT )
    end

    ---
    -- Draws the inventory screen.
    --
    function self:draw()
        background:draw()
        outlines:draw()

        for _, list in pairs( lists ) do
            list:draw()
        end

        for _, label in pairs( listLabels ) do
            label:draw()
        end

        -- Highlight equipment slot if draggable item can be put there.
        lists.equipment:highlight( dragboard:getDragContext() and dragboard:getDraggedItem() )

        itemStats:draw()
        dragboard:draw( lists )
    end

    ---
    -- This method is called when the inventory screen is closed.
    --
    function self:close()
        love.mouse.setVisible( false )

        -- Drop any item that is currently dragged.
        if dragboard:hasDragContext() then
            dragboard:drop()
        end
    end

    -- ------------------------------------------------
    -- Input Callbacks
    -- ------------------------------------------------

    function self:keypressed( key )
        if key == 'escape' or key == 'i' then
            ScreenManager.pop()
        end

        itemStats:keypressed( key )
    end

    function self:mousepressed( mx, my, button )
        local gx, gy = GridHelper.pixelsToGrid( mx, my )

        if button == 2 then
            selectItem()
        end
        drag( button )

        itemStats:mousepressed( gx, gy, button )
    end

    function self:mousereleased( _, _, _ )
        if not dragboard:hasDragContext() then
            return
        end

        local list = getListBelowCursor()
        dragboard:drop( list )

        -- Refresh lists in case volumes have changed.
        refreshLists()
    end

    function self:wheelmoved( dx, dy )
        itemStats:wheelmoved( dx, dy )
    end

    return self
end

return InventoryScreen
