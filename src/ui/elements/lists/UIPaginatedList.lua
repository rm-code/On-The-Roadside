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
        items[i]:setRelativePosition( ax, ay + #currentPage-1 )

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
-- Adds the list of items to display in this paginated list.
-- @tparam table items A sequence containing the UIElements to add to the list.
--
function UIPaginatedList:setItems( items )
    self.maxPages = calculateMaximumPages( #items, self.h )
    self.pages = fillPages( items, self.maxPages, self.h, self.ax, self.ay )

    -- Create buttons for the status bar if we have more than one page.
    if #self.pages > 1 then
        self:addButtons()
    end

    -- Set focus to the first item on the list.
    self.pages[self.currentPage][self.cursor]:setFocus( true )
end

---
-- Creates the buttons to scroll through the pages.
--
function UIPaginatedList:addButtons()
    self.buttonPrev = UIButton( 0, 0, self.ax + self.w-2, self.ay + self.h-1, 1, 1, function() self:scrollPage( -1 ) end )
    self.buttonPrev:setIcon( 'ui_prev_element' )
    self.buttonNext = UIButton( 0, 0, self.ax + self.w-1, self.ay + self.h-1, 1, 1, function() self:scrollPage( 1 ) end )
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

    self.currentPage = Util.clamp( 1, self.currentPage + direction, self.maxPages )

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
    for _, item in ipairs( self.pages[self.currentPage] ) do
        if item:isMouseOver() then
            item:command( cmd )
            return
        end
    end

    for i = 1, #self.children do
        if self.children[i]:isMouseOver() then
            self.children[i]:command( cmd )
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

return UIPaginatedList
