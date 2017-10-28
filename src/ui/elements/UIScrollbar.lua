---
-- @module UIScrollbar
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UIElement = require( 'src.ui.elements.UIElement' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIScrollbar = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local MIN_CURSOR_HEIGHT = 1

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UIScrollbar.new( px, py, x, y, w, h )
    local self = UIElement.new( px, py, x, y, w, h ):addInstance( 'UIScrollbar' )

    -- ------------------------------------------------
    -- Private attributes
    -- ------------------------------------------------

    local tileset = TexturePacks.getTileset()
    local cursor  = TexturePacks.getSprite( 'ui_scrollbar_cursor' )
    local element = TexturePacks.getSprite( 'ui_scrollbar_element' )

    local viewportHeight
    local contentHeight

    local viewportContentRatio

    local cursorHeight
    local barScrollableHeight
    local cursorPosition

    local maxOffset

    local callback

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    local function calculateViewportContentRatio()
        return viewportHeight / contentHeight
    end

    local function calculateCursorHeight()
        return math.min( math.max( self.h * viewportContentRatio, MIN_CURSOR_HEIGHT ), self.h )
    end

    local function calculateCursorPosition( offset )
        return (offset / maxOffset) * barScrollableHeight
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    ---
    -- @tparam number maxOffset The maximum offset the scroll content can have.
    --
    function self:init( nviewportHeight, ncontentHeight, nmaxOffset, ncallback )
        -- Initialise variables.
        viewportHeight = nviewportHeight
        contentHeight = ncontentHeight
        maxOffset = nmaxOffset
        callback = ncallback

        -- The ratio between the viewport and the content to display.
        viewportContentRatio = calculateViewportContentRatio()

        cursorHeight = calculateCursorHeight()
        barScrollableHeight = self.h - cursorHeight

        cursorPosition = calculateCursorPosition( 0 )
    end

    function self:draw()
        local tw, th = TexturePacks.getTileDimensions()

        -- Draw the bar.
        for oy = 0, self.h-1 do
            TexturePacks.setColor( 'ui_scrollbar_element' )
            love.graphics.draw( tileset:getSpritesheet(), element, self.ax * tw, (self.ay+oy) * th )
        end

        -- Draw the cursor.
        for oy = 0, cursorHeight-1 do
            TexturePacks.setColor( 'ui_scrollbar_cursor' )
            love.graphics.draw( tileset:getSpritesheet(), cursor, self.ax * tw, math.ceil((self.ay+oy+cursorPosition) * th ))
        end

        TexturePacks.resetColor()
    end

    ---
    -- @tparam number offset The offset of the scroll content [-n, 0].
    --
    function self:scroll( offset )
        cursorPosition = calculateCursorPosition( offset )
    end

    function self:mousepressed( _, my )
        if my < self.ay+cursorPosition+(cursorHeight*0.5) then
            callback( -4 )
        elseif my > self.ay+cursorPosition+(cursorHeight*0.5) then
            callback( 4 )
        end
    end

    return self
end

return UIScrollbar
