---
-- @module InventoryScreen
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Screen = require( 'src.ui.screens.Screen' )
local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local UIOutlines = require( 'src.ui.elements.UIOutlines' )
local UIBackground = require( 'src.ui.elements.UIBackground' )
local UIEquipmentList = require( 'src.ui.elements.inventory.UIEquipmentList' )
local UIInventoryList = require( 'src.ui.elements.inventory.UIInventoryList' )
local UILabel = require( 'src.ui.elements.UILabel' )
local UIInventoryDragboard = require( 'src.ui.elements.inventory.UIInventoryDragboard' )
local UIItemStats = require( 'src.ui.elements.inventory.UIItemStats' )
local GridHelper = require( 'src.util.GridHelper' )
local Translator = require( 'src.util.Translator' )
local Container = require( 'src.items.Container' )
local Settings = require( 'src.Settings' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local InventoryScreen = Screen:subclass( 'InventoryScreen' )

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
-- Private Methods
-- ------------------------------------------------

---
-- Creates the outlines for the Inventory window.
-- @tparam  number     x The origin of the screen along the x-axis.
-- @tparam  number     y The origin of the screen along the y-axis.
-- @treturn UIOutlines   The newly created UIOutlines instance.
--
local function generateOutlines( x, y )
    local outlines = UIOutlines( x, y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )

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
    return outlines
end

---
-- Creates the equipment list for the currently selected character and the
-- associated header label.
-- @tparam number    x          The origin of the screen along the x-axis.
-- @tparam number    y          The origin of the screen along the y-axis.
-- @tparam Character character  The character to use for the equipment list.
-- @tparam table     lists      A table containing the different inventories.
-- @tparam table     listLabels A table containing the labels for each inventory list.
-- @tparam Inventory dropInventory The inventory to use when dropping items.
--
local function createEquipmentList( x, y, character, lists, listLabels, dropInventory )
    -- Offset calculations:
    --  x-axis: Outline left => 1
    --  y-axis: Outline top + Header Text + Outline below Header => 3
    local ox, oy = 1, 3
    lists.equipment = UIEquipmentList( x, y, ox, oy, EQUIPMENT_WIDTH, EQUIPMENT_HEIGHT, character, dropInventory )

    -- Offset calculations:
    --  x-axis: Outline left => 1
    --  y-axis: Outline top => 1
    local lx, ly = 1, 1
    listLabels.equipment = UILabel( x, y, lx, ly, EQUIPMENT_WIDTH, 1, Translator.getText( 'inventory_equipment' ), 'ui_inventory_headers' )
end

---
-- Creates the character's "backpack" inventory in which all items he carries
-- are stored and the associated header label.
-- @tparam number    x          The origin of the screen along the x-axis.
-- @tparam number    y          The origin of the screen along the y-axis.
-- @tparam Character character  The character to use for the equipment list.
-- @tparam table     lists      A table containing the different inventories.
-- @tparam table     listLabels A table containing the labels for each inventory list.
--
local function createCharacterInventoryList( x, y, character, lists, listLabels )
    -- Offset calculations:
    --  x-axis: Outline left + Equipment Column + Equipment Column Outline
    --      => 1 + COLUMN_WIDTH + 1
    --      => 2 + COLUMN_WIDTH
    --  y-axis: Outline top + Header Text + Outline below Header => 3
    local ox, oy = 2 + COLUMN_WIDTH, 3
    lists.characterInventory = UIInventoryList( x, y, ox, oy, COLUMN_WIDTH, COLUMN_HEIGHT, character:getInventory() )

    -- Label coordinates relative to the screen's coordinates.
    --      x-axis: Outline left + Equipment Column + Equipment Column Outline
    --              => 1 + COLUMN_WIDTH + 1
    --              => 2 + COLUMN_WIDTH
    --      y-axis: Outline top => 1
    local lx, ly = 2 + COLUMN_WIDTH, 1
    listLabels.characterInventory = UILabel( x, y, lx, ly, COLUMN_WIDTH, 1, Translator.getText( 'inventory_character' ), 'ui_inventory_headers' )
end

---
-- Creates the target inventory with which the character wants to interact and
-- its associated header label.
-- @tparam number x          The origin of the screen along the x-axis.
-- @tparam number y          The origin of the screen along the y-axis.
-- @tparam string targetID   The inventory ID.
-- @tparam Tile   target     The target tile to interact with.
-- @tparam table  lists      A table containing the different inventories.
-- @tparam table  listLabels A table containing the labels for each inventory list.
--
local function createTargetInventoryList(  x, y, targetID, target, lists, listLabels )
    local id, inventory = targetID, target

    -- Offset calculations:
    --  x-axis: Outline left + Equipment Column + Equipment Column Outline
    --          + Character Inventory Column + Character Inventory Column Outline
    --          => 1 + COLUMN_WIDTH + 1 + COLUMN_WIDTH + 1
    --          => 3 + 2 * COLUMN_WIDTH
    --  y-axis: Outline top + Header Text + Outline below Header => 3
    local ox, oy = 3 + 2 * COLUMN_WIDTH, 3
    lists.targetInventory = UIInventoryList( x, y, ox, oy, COLUMN_WIDTH, COLUMN_HEIGHT, inventory )

    -- Offset calculations:
    --  x-axis: Outline left + Equipment Column + Equipment Column Outline
    --          + Character Inventory Column + Character Inventory Column Outline
    --          => 1 + COLUMN_WIDTH + 1 + COLUMN_WIDTH + 1
    --          => 3 + 2 * COLUMN_WIDTH
    --  y-axis: Outline top => 1
    local lx, ly = 3 + 2 * COLUMN_WIDTH, 1
    listLabels.targetInventory = UILabel( x, y, lx, ly, COLUMN_WIDTH, 1, Translator.getText( id ), 'ui_inventory_headers' )
end

---
-- Creates the equipment and inventory lists.
-- @tparam  number    x         The origin of the screen along the x-axis.
-- @tparam  number    y         The origin of the screen along the y-axis.
-- @tparam  Character character The character to use for the equipment list.
-- @tparam  string    targetID  The inventory ID.
-- @tparam  Tile      target    The target tile to interact with.
-- @tparam  Inventory dropInventory The inventory to use when dropping items.
-- @treturn table               The table containing the different inventory lists.
-- @treturn table               The table containing a label for each inventory list.
--
local function createInventoryLists( x, y, character, targetID, target, dropInventory )
    local lists = {}
    local listLabels = {}

    createEquipmentList( x, y, character, lists, listLabels, dropInventory )
    createCharacterInventoryList( x, y, character, lists, listLabels )
    createTargetInventoryList( x, y, targetID, target, lists, listLabels )

    return lists, listLabels
end

---
-- Returns the list the mouse is currently over.
-- @tparam table lists A table containing the different inventories.
-- @treturn table The equipment or inventory list the mouse is over.
--
local function getListBelowCursor( lists )
    for _, list in pairs( lists ) do
        if list:isMouseOver() then
            return list
        end
    end
end

---
-- Refreshes all inventor lists.
-- @tparam table lists A table containing the different inventories.
--
local function refreshLists( lists )
    for _, list in pairs( lists ) do
        list:refresh()
    end
end

---
-- Initiates a drag action.
-- @tparam table                lists     A table containing the different inventories.
-- @tparam UIInventoryDragboard dragboard The dragboard containing the current dragged item.
-- @tparam UIItemStats          itemStats The itemStats object to set the item for.
-- @tparam boolean              stack     Wether or not to drag a full stack.
--
local function drag( lists, dragboard, itemStats, stack )
    -- Can't drag if we are already dragging.
    if dragboard:hasDragContext() then
        return
    end

    -- Can't drag if not over a list.
    local list = getListBelowCursor( lists )
    if not list then
        return
    end

    local item, origin, slot = list:drag( stack )

    -- Abort if there is nothing to drag here.
    if not item then
        return
    end

    -- Display stats for the dragged item.
    itemStats:setItem( item )

    -- Add the item and list to the dragboard. If the item comes from the
    -- equipment list we also pass the slot.
    dragboard:drag( item, origin or list, slot )

    -- If the dragged item is a container we need to refresh the inventory lists
    -- because it changes the inventory volumes.
    if item:isInstanceOf( Container ) then
        refreshLists( lists )
    end
end

local function splitStack( lists, dragboard, itemStats )
    -- Can't drag if we are already dragging.
    if dragboard:hasDragContext() then
        return
    end

    -- Can't drag if not over a list.
    local list = getListBelowCursor( lists )
    if not list then
        return
    end

    local item, origin, slot = list:splitStack()
    -- Abort if there is nothing to drag here.
    if not item then
        return
    end

    -- Display stats for the dragged item.
    itemStats:setItem( item )

    -- Add the item and list to the dragboard. If the item comes from the
    -- equipment list we also pass the slot.
    dragboard:drag( item, origin or list, slot )

    -- If the dragged item is a container we need to refresh the inventory lists
    -- because it changes the inventory volumes.
    if item:isInstanceOf( Container ) then
        refreshLists( lists )
    end
end

---
-- Selects an item for the item stats area.
-- @tparam table       lists     A table containing the different inventories.
-- @tparam UIItemStats itemStats The itemStats object to set the item for.
--
local function selectItem( lists, itemStats )
    local list = getListBelowCursor( lists )
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
-- @tparam Character character The character to open the inventory for.
-- @tparam string    targetID  The inventory ID.
-- @tparam Tile      target    The target tile to open the inventory for.
-- @tparam Inventory dropInventory The inventory to use when dropping items.
--
function InventoryScreen:initialize( character, targetID, target, dropInventory )
    love.mouse.setVisible( true )

    self.x, self.y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )

    -- General UI Elements.
    self.background = UIBackground( self.x, self.y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )
    self.outlines = generateOutlines( self.x, self.y )

    -- UI inventory lists.
    self.lists, self.listLabels = createInventoryLists( self.x, self.y, character, targetID, target, dropInventory )

    self.dragboard = UIInventoryDragboard()

    -- Add the item stats area which displays the item attributes and a description area.
    --      x-axis: Outline left => 1
    --      y-axis: Outline top + Header + Outl ine Header
    --              + Outline below equipment + EQUIPMENT_HEIGHT
    --              => EQUIPMENT_HEIGHT+4
    self.itemStats = UIItemStats( self.x, self.y, 1, EQUIPMENT_HEIGHT+4, ITEM_STATS_WIDTH, ITEM_STATS_HEIGHT )
end

---
-- Draws the inventory screen.
--
function InventoryScreen:draw()
    self.background:draw()
    self.outlines:draw()

    for _, list in pairs( self.lists ) do
        list:draw()
    end

    for _, label in pairs( self.listLabels ) do
        label:draw()
    end

    -- Highlight equipment slot if draggable item can be put there.
    self.lists.equipment:highlight( self.dragboard:getDragContext() and self.dragboard:getDraggedItem() )

    self.itemStats:draw()
    self.dragboard:draw( self.lists )
end

---
-- This method is called when the inventory screen is closed.
--
function InventoryScreen:close()
    -- Drop any item that is currently dragged.
    if self.dragboard:hasDragContext() then
        self.dragboard:drop()
    end
end

-- ------------------------------------------------
-- Input Callbacks
-- ------------------------------------------------

function InventoryScreen:keypressed( key, scancode )
    if key == 'escape' or key == 'i' then
        ScreenManager.pop()
    end

    if scancode == 'up' then
        self.itemStats:command( 'up' )
    elseif scancode == 'down' then
        self.itemStats:command( 'down' )
    end
end

function InventoryScreen:mousepressed( _, _, button )
    if button == 2 then
        selectItem( self.lists, self.itemStats )
        return
    end
end

function InventoryScreen:mousereleased( _, _, _ )
    self.itemStats:command( 'activate' )
end

function InventoryScreen:mousedragstarted()
    if love.keyboard.isDown( Settings.mapAction( 'inventory', 'split_item_stack' )) then
        splitStack( self.lists, self.dragboard, self.itemStats )
        return
    end

    if love.keyboard.isDown( Settings.mapAction( 'inventory', 'drag_item_stack' )) then
        drag( self.lists, self.dragboard, self.itemStats, true )
        return
    end

    drag( self.lists, self.dragboard, self.itemStats, false )
end

function InventoryScreen:mousedragstopped()
    if self.dragboard:hasDragContext() then
        local list = getListBelowCursor( self.lists )
        self.dragboard:drop( list )

        -- Refresh lists in case volumes have changed.
        refreshLists( self.lists )
        return
    end
end

function InventoryScreen:wheelmoved( _, dy )
    self.itemStats:command( 'scroll', dy )
end

-- ------------------------------------------------
-- Other Callbacks
-- ------------------------------------------------

function InventoryScreen:resize( _, _ )
    self.x, self.y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )
    self.background:setOrigin( self.x, self.y )
    self.outlines:setOrigin( self.x, self.y )
    self.itemStats:setOrigin( self.x, self.y )
    for _, list in pairs( self.lists ) do
        list:setOrigin( self.x, self.y )
    end
    for _, label in pairs( self.listLabels ) do
        label:setOrigin( self.x, self.y )
    end
end

return InventoryScreen
