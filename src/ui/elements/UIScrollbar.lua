---
-- @module UIScrollbar
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UIElement = require( 'src.ui.elements.UIElement' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local GridHelper = require( 'src.util.GridHelper' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIScrollbar = UIElement:subclass( 'UIScrollbar' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local MIN_CURSOR_HEIGHT = 1


-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

local function calculateViewportContentRatio( viewportHeight, contentHeight )
    return viewportHeight / contentHeight
end

local function calculateCursorHeight( height, viewportContentRatio )
    return math.min( math.max( height * viewportContentRatio, MIN_CURSOR_HEIGHT ), height )
end

local function calculateCursorPosition( self, offset )
    return ( offset / self.maxOffset ) * self.scrollableHeight
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function UIScrollbar:initialize( px, py, x, y, w, h, viewportHeight, contentHeight, maxOffset, callback )
    UIElement.initialize( self, px, py, x, y, w, h )

    self.cursor  = TexturePacks.getSprite( 'ui_scrollbar_cursor' )
    self.element = TexturePacks.getSprite( 'ui_scrollbar_element' )

    -- The ratio between the viewport and the content to display.
    local viewportContentRatio = calculateViewportContentRatio( viewportHeight, contentHeight )

    self.maxOffset = maxOffset
    self.cursorHeight = calculateCursorHeight( self.h, viewportContentRatio )
    self.scrollableHeight = self.h - self.cursorHeight
    self.cursorPosition = calculateCursorPosition( self, 0 )

    self.callback = callback
end

function UIScrollbar:draw()
    local tw, th = TexturePacks.getTileDimensions()

    -- Draw the bar.
    for oy = 0, self.h-1 do
        TexturePacks.setColor( 'ui_scrollbar_element' )
        love.graphics.draw( TexturePacks.getTileset():getSpritesheet(), self.element, self.ax * tw, (self.ay+oy) * th )
    end

    -- Draw the cursor.
    for oy = 0, self.cursorHeight-1 do
        TexturePacks.setColor( 'ui_scrollbar_cursor' )
        love.graphics.draw( TexturePacks.getTileset():getSpritesheet(), self.cursor, self.ax * tw, math.ceil((self.ay+oy+self.cursorPosition) * th ))
    end

    TexturePacks.resetColor()
end

---
-- @tparam number offset The offset of the scroll content [-n, 0].
--
function UIScrollbar:scroll( offset )
    self.cursorPosition = calculateCursorPosition( self, offset )
end

function UIScrollbar:command( cmd )
    if cmd == 'activate' then
        local _, gy = GridHelper.getMouseGridPosition()
        if gy < self.ay + self.cursorPosition + (self.cursorHeight * 0.5) then
            self.callback( -4 )
        elseif gy > self.ay + self.cursorPosition + (self.cursorHeight * 0.5) then
            self.callback( 4 )
        end
    end
end

return UIScrollbar
