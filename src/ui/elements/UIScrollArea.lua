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
    local font
    local offset
    local scrollAreaHeight

    local scrollable

    local upButton
    local downButton
    local scrollbar

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    local function calculateContentHeight()
        return text:getHeight() / TexturePacks.getFont():getGlyphHeight()
    end

    -- ------------------------------------------------
    -- Public Method
    -- ------------------------------------------------

    function self:init( textString )
        font = TexturePacks.getFont():get()
        text = love.graphics.newText( font )
        offset = 0

        self:setText( textString, self.w, self.h )

        if scrollable then

            -- The height of the scroll content in grid space.
            local contentHeight = calculateContentHeight()

            -- The max offset is calculated by taking the height of the scroll area
            -- the text height (transformed to grid space). This will stop the scroll
            -- offset as soon as the last line hits the bottom of the scroll area.
            scrollAreaHeight = contentHeight - self.h

            -- The up button is placed in the top right corner of the scroll area.
            upButton = UIButton.new( self.ax, self.ay, self.w-1, 0, 1, 1 )
            upButton:init( 'ui_scroll_area_up', function() self:scroll(-1) end )

            downButton = UIButton.new( self.ax, self.ay, self.w-1, self.h-1, 1, 1 )
            downButton:init( 'ui_scroll_area_down', function() self:scroll(1) end )

            -- Scroll bar is positioned between the buttons.
            scrollbar = UIScrollbar.new( self.ax, self.ay, self.w-1, 1, 1, self.h-2, 'ui_scroll_area_down' )
            scrollbar:init( self.h, contentHeight, scrollAreaHeight, function( noffset ) self:scroll( noffset ) end )
        end
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

    function self:setPosition( nx, ny )
        self.ox = nx
        self.oy = ny

        if not scrollable then
            return
        end

        local rx, ry = self:getRelativePosition()
        upButton:setOrigin( nx+rx, ny+ry )
        downButton:setOrigin( nx+rx, ny+ry )
        scrollbar:setOrigin( nx+rx, ny+ry )
    end

    function self:setText( textString, gw, gh )
        local tw, _ = TexturePacks.getTileDimensions()

        -- The text wrap is one smaller than the scroll area to provide space
        -- for the scrollbar.
        text:setf( textString, gw * tw, 'left' )

        -- If the scroll content is bigger than the viewport we add scrollbars.
        local textGridHeight = calculateContentHeight()
        if textGridHeight > gh then
            text:setf( textString, (gw-1) * tw, 'left' )
            scrollable = true
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
