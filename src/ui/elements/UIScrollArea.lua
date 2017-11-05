---
-- @module UIScrollArea
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UIElement = require( 'src.ui.elements.UIElement' )
local UIButton = require( 'src.ui.elements.UIButton' )
local UIScrollbar = require( 'src.ui.elements.UIScrollbar' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIScrollArea = {}

function UIScrollArea.new( px, py, x, y, w, h )
    local self = UIElement.new( px, py, x, y, w, h ):addInstance( 'UIScrollArea' )

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local text
    local offset
    local scrollAreaHeight

    local scrollable

    local upButton
    local downButton
    local scrollbar

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    local function createScrollbar( height )
        scrollable = true

        -- The height of the scroll content in grid space.
        local contentHeight = height / TexturePacks.getFont():getGlyphHeight()

        -- The max offset is calculated by taking the height of the scroll area
        -- the text height (transformed to grid space). This will stop the scroll
        -- offset as soon as the last line hits the bottom of the scroll area.
        scrollAreaHeight = contentHeight - self.h

        -- The up button is placed in the top right corner of the scroll area.
        upButton = UIButton.new( self.ax, self.ay, self.w-1, 0, 1, 1 )
        upButton:init( 'ui_scroll_area_up', function() self:scroll(-1) end )
        self:addChild( upButton )

        downButton = UIButton.new( self.ax, self.ay, self.w-1, self.h-1, 1, 1 )
        downButton:init( 'ui_scroll_area_down', function() self:scroll(1) end )
        self:addChild( downButton )

        -- Scroll bar is positioned between the buttons.
        scrollbar = UIScrollbar.new( self.ax, self.ay, self.w-1, 1, 1, self.h-2, 'ui_scroll_area_down' )
        scrollbar:init( self.h, contentHeight, scrollAreaHeight, function( noffset ) self:scroll( noffset ) end )
        self:addChild( scrollbar )
    end

    -- ------------------------------------------------
    -- Public Method
    -- ------------------------------------------------

    function self:init( ntext, nheight )
        offset = 0
        self:setText( ntext, nheight )
    end

    function self:draw()
        local tw, th = TexturePacks.getTileDimensions()

        love.graphics.setScissor( self.ax * tw, self.ay * th, self.w * tw, self.h * th )
        love.graphics.draw( text, self.ax * tw, (self.ay-offset) * th )
        love.graphics.setScissor()

        if scrollable then
            upButton:draw()
            downButton:draw()
            scrollbar:draw()
        end
    end

    function self:scroll( dir )
        if not scrollable then
            return
        end

        offset = offset + dir
        offset = math.max( 0, math.min( offset, scrollAreaHeight ))
        scrollbar:scroll( offset )
    end

    function self:setText( ntext, nheight )
        text = ntext

        local _, gh = TexturePacks.getGlyphDimensions()
        if math.floor( nheight / gh ) > self.h then
            createScrollbar( nheight )
        else
            scrollable = false
        end
    end

    function self:mousepressed( mx, my )
        if not scrollable then
            return
        end

        if upButton:isMouseOver() then
            upButton:activate()
        elseif downButton:isMouseOver() then
            downButton:activate()
        elseif scrollbar:isMouseOver() then
            scrollbar:mousepressed( mx, my )
        end
    end

    return self
end

return UIScrollArea
