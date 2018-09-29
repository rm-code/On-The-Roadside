---
-- Displays a set of UIElements as a scrollable list distributed across multiple
-- pages. If all items fit on one page the status bar at the bottom of the list
-- will be hidden.
--
-- @module UIPaginatedList
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UIElement = require( 'src.ui.elements.UIElement' )
local UIDummy = require( 'src.ui.elements.UIDummy' )
local UIButton = require( 'src.ui.elements.UIButton' )
local Util = require( 'src.util.Util' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIPaginatedList = UIElement:subclass( 'UIPaginatedList' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Calculates the maximum amount of pages needed to fit all items.
-- @tparam number numberOfItems The total amout of items to fit into the list.
-- @tparam number height        The list's height.
-- @tparam number               The maximum amount of pages to create.
--
local function calculateMaximumPages( numberOfItems, height )
    -- Check if we can fit the list on one page if we hide the status bar.
    if numberOfItems <= height then
        return 1
    end
    -- Calculate pages with the status bar taken into account.
    return math.ceil( numberOfItems / ( height-1 ))
end

---
-- Fills the pages with items.
-- @tparam table  items        A sequence containing the UIElements to add to the list.
-- @tparam number maximumPages The maximum amount of pages to create.
-- @tparam number height       The list's height.
-- @tparam number ax           The list's absolute coordinate along the x-axis.
-- @tparam number ay           The list's absolute coordinate along the y-axis.
-- @treturn table              The created pages.
--
local function fillPages( items, maximumPages, height, ax, ay )
    -- If we only have to create one page we can use its full height because the
    -- status bar is hidden.
    local maxItemsPerPage = maximumPages <= 1 and height or (height-1)

    local pages = {}
    local currentPage = {}

    for i = 1, #items do
        currentPage[#currentPage + 1] = items[i]
        items[i]:setFocus( false )
        items[i]:setOrigin( ax, ay )
        items[i]:setRelativePosition( 0, #currentPage-1 )

        -- Add the current page to the "pages" table if it is full or if we have
        -- added all the items to add.
        if #currentPage == maxItemsPerPage or i == #items then
            pages[#pages+1] = currentPage
            currentPage = {}
        end
    end

    return pages
end

---
-- Draws the page numbers.
-- @tparam number currentPage The current page index.
-- @tparam number maxPages    The maximum amount of pages.
-- @tparam number px          The absolute coordinate along the x-axis.
-- @tparam number py          The absolute coordinate along the y-axis.
-- @tparam number w           The list's width.
--
local function drawPageNumbers( currentPage, maxPages, px, py, w )
    local tw, th = TexturePacks.getTileDimensions()

    local text = string.format( '%d/%d', currentPage, maxPages )
    local offset = TexturePacks.getFont():align( 'right', text, (w-2) * tw )

    TexturePacks.setColor( 'ui_text_dark' )
    love.graphics.print( text, px * tw + offset, py * th )
    TexturePacks.resetColor()
end

---
-- Adds an item to the paginated list.
-- If a dummy item is used, it will be replaced.
-- @tparam UIPaginatedList self The list instance to use.
-- @tparam UIElement       item The item to add.
--
local function addItem( self, item )
    -- Replace dummy element.
    if self.dummy then
        self.items[#self.items] = item
        self.dummy = false
        return
    end

    -- Add item normally.
    self.items[#self.items + 1] = item
    return
end

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

---
-- Creates a new UIPaginatedList.
-- @tparam number ox The origin along the x-axis.
-- @tparam number oy The origin along the y-axis.
-- @tparam number rx The relative coordinate along the x-axis.
-- @tparam number ry The relative coordinate along the y-axis.
-- @tparam number w  The width of this element.
-- @tparam number h  The height of this element.
--
function UIPaginatedList:initialize( ox, oy, rx, ry, w, h )
    UIElement.initialize( self, ox, oy, rx, ry, w, h )

    self.pages = {}
    self.currentPage = 1
    self.cursor = 1

    self.dummy = false
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Draws the UIPaginatedList.
--
function UIPaginatedList:draw()
    -- Draw the current page.
    for _, item in ipairs( self.pages[self.currentPage] ) do
        item:draw()
    end

    -- Draw the status bar if we have more than one page.
    if self.maxPages > 1 then
        drawPageNumbers( self.currentPage, self.maxPages, self.ax, self.ay + self.h - 1, self.w )

        -- Hide prev button if we reached the first page.
        if self.currentPage > 1 then
            self.buttonPrev:draw()
        end

        -- Hide the next button if we reached the last page.
        if self.currentPage < self.maxPages then
            self.buttonNext:draw()
        end
    end
end

---
-- Updates the UIPaginatedList.
--
function UIPaginatedList:update()
    if not love.mouse.isVisible() then
        return
    end

    for i, item in ipairs( self.pages[self.currentPage] ) do
        item:setFocus( false )
        if item:isMouseOver() then
            item:setFocus( true )
            self.cursor = i
        end
    end
end

---
-- Generates the pages based on the amount of added items.
--
function UIPaginatedList:generatePagination()
    -- Create dummy element.
    if #self.items == 0 then
        self.items[1] = UIDummy( 0, 0, 0, 0, 0, 0 )
        self.dummy = true
    end

    self.maxPages = calculateMaximumPages( #self.items, self.h )
    self.pages = fillPages( self.items, self.maxPages, self.h, self.ax, self.ay )

    -- Create buttons for the status bar if we have more than one page.
    if #self.pages > 1 then
        self:addButtons()
    end

    while not self.pages[self.currentPage] do
        self.currentPage = self.currentPage - 1
    end

    while not self.pages[self.currentPage][self.cursor] do
        self.cursor = self.cursor - 1
    end

    -- Set focus to the first item on the list.
    self.pages[self.currentPage][self.cursor]:setFocus( true )
end

---
-- Adds the list of items to display in this paginated list.
-- @tparam table items A sequence containing the UIElements to add to the list.
--
function UIPaginatedList:setItems( items )
    self.items = items
    self:generatePagination()
end

---
-- Gets the list of items displayed in this paginated list.
-- If the list contains a dummy item a dummy table is returned instead.
-- @treturn table A sequence containing the UIElements on this list.
--
function UIPaginatedList:getItems()
    return self.dummy and {} or self.items
end

---
-- Counts the amount of items in this paginated list.
-- If the list contains a dummy item the returned value is zero.
-- @treturn number The amount of items on the list.
--
function UIPaginatedList:getItemCount()
    if self.dummy then
        return 0
    end
    return #self.items
end

---
-- Creates the buttons to scroll through the pages.
--
function UIPaginatedList:addButtons()
    self.buttonPrev = UIButton( self.ax, self.ay, self.w-2, self.h-1, 1, 1, function() self:scrollPage( -1 ) end )
    self.buttonPrev:setIcon( 'ui_prev_element' )
    self.buttonNext = UIButton( self.ax, self.ay, self.w-1, self.h-1, 1, 1, function() self:scrollPage( 1 ) end )
    self.buttonNext:setIcon( 'ui_next_element' )

    self:addChild( self.buttonPrev )
    self:addChild( self.buttonNext )
end

---
-- Scrolls through the pages and stops when we reach the ends of the list.
-- @tparam number direction The direction to scroll to (1, -1).
--
function UIPaginatedList:scrollPage( direction )
    if self.pages[self.currentPage][self.cursor] then
        self.pages[self.currentPage][self.cursor]:setFocus( false )
    end

    -- Stop at the first and the last page.
    self.currentPage = Util.clamp( 1, self.currentPage + direction, self.maxPages )

    -- Prevent cursor from jumping to an item that doesn't exist on the last page.
    -- This can happen for example if the last page only has four items, but the
    -- cursor was focused on the ninth item on the second to last page.
    self.cursor = Util.clamp( 1, self.cursor, #self.pages[self.currentPage] )

    -- Focus the item at the cursor's position on the new page.
    self.pages[self.currentPage][self.cursor]:setFocus( true )
end

---
-- Scrolls through the items and wraps around the ends of the list.
-- @tparam number direction The direction to scroll to (1, -1).
--
function UIPaginatedList:scrollItem( direction )
    if self.pages[self.currentPage][self.cursor] then
        self.pages[self.currentPage][self.cursor]:setFocus( false )
        self.cursor = Util.wrap( 1, self.cursor + direction, #self.pages[self.currentPage] )
    else
        self.cursor = 1
    end

    self.pages[self.currentPage][self.cursor]:setFocus( true )
end

---
-- Fowards a command to the currently focused UIElement.
-- @tparam string cmd The command to forward.
--
function UIPaginatedList:command( cmd )
    if self.dummy then
        return
    end

    -- Scroll through items.
    if cmd == 'up' then
        self:scrollItem( -1 )
    elseif cmd == 'down' then
        self:scrollItem( 1 )
    end

    -- Scroll through pages.
    if cmd == 'right' then
        self:scrollPage( 1 )
    elseif cmd == 'left' then
        self:scrollPage( -1 )
    end

    if cmd == 'activate' and self.pages[self.currentPage][self.cursor] then
        self.pages[self.currentPage][self.cursor]:command( cmd )
    end
end

---
-- Fowards a mousecommand to the children and items on the current page.
-- @tparam string cmd The command to forward.
--
function UIPaginatedList:mousecommand( cmd )
    if self.dummy then
        return
    end

    for _, item in ipairs( self.pages[self.currentPage] ) do
        if item:isMouseOver() then
            item:mousecommand( cmd )
            return
        end
    end

    for i = 1, #self.children do
        if self.children[i]:isMouseOver() then
            self.children[i]:mousecommand( cmd )
            return
        end
    end
end

---
-- Forwards changes to the focus to the children and items on the current page.
-- @tparam boolean focus Wether the element should be focused or not.
--
function UIPaginatedList:setFocus( focus )
    UIPaginatedList.super.setFocus( self, focus )
    self.pages[self.currentPage][self.cursor]:setFocus( focus )
end

---
-- Forwards changes to the origin of the paginated list to the children and
-- all items on each page.
-- @tparam number ox The new origin along the x-axis.
-- @tparam number oy The new origin along the y-axis.
--
function UIPaginatedList:setOrigin( ox, oy )
    UIPaginatedList.super.setOrigin( self, ox, oy )

    for _, page in ipairs( self.pages ) do
        for _, item in ipairs( page ) do
            item:setOrigin( self.ax, self.ay )
        end
    end
end

---
-- Sorts the items of the paginated list by the provided category and restarts
-- the pagination process.
-- @tparam boolean ascending Wether to sort the items ascending or descending.
-- @tparam string  category  The category by which to sort the list.
--
function UIPaginatedList:sort( ascending, category )
    for i = 1, #self.items do
        self.items[i]:setFocus( false )
    end

    if ascending then
        table.sort( self.items, function( a, b )
            return a.sortCategories[category] > b.sortCategories[category]
        end)
    else
        table.sort( self.items, function( a, b )
            return a.sortCategories[category] < b.sortCategories[category]
        end)
    end

    self:generatePagination()
end

---
-- Removes an item from the paginated list and restarts the pagination process.
-- @tparam UIElement item The ui element to remove.
--
function UIPaginatedList:removeItem( item )
    for i = 1, #self.items do
        if self.items[i] == item then
            table.remove( self.items, i )
            break
        end
    end
    self:generatePagination()
end

---
-- Adds a single item to the list and restarts the pagination.
-- @tparam UIElement item The ui element to add.
--
function UIPaginatedList:addItem( item )
    addItem( self, item )
    self:generatePagination()
end

---
-- Adds multiple item to the list and restarts the pagination.
-- @tparam table items A sequence containing the UIElements to add.
--
function UIPaginatedList:addItems( items )
    for i = 1, #items do
        addItem( self, items[i] )
    end
    self:generatePagination()
end

return UIPaginatedList
