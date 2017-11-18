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

local UIScrollArea = UIElement:subclass( 'UIScrollArea' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

local function createScrollbar( self, height )
    self.scrollable = true

    -- The height of the scroll content in grid space.
    local contentHeight = height / TexturePacks.getFont():getGlyphHeight()

    -- The max offset is calculated by taking the height of the scroll area
    -- the text height (transformed to grid space). This will stop the scroll
    -- offset as soon as the last line hits the bottom of the scroll area.
    self.scrollAreaHeight = contentHeight - self.h

    -- The up button is placed in the top right corner of the scroll area.
    self.upButton = UIButton( self.ax, self.ay, self.w-1, 0, 1, 1, function() self:scroll(-1) end )
    self.upButton:setIcon( 'ui_scroll_area_up' )
    self:addChild( self.upButton )

    self.downButton = UIButton( self.ax, self.ay, self.w-1, self.h-1, 1, 1, function() self:scroll(1) end )
    self.downButton:setIcon( 'ui_scroll_area_down' )
    self:addChild( self.downButton )

    -- Scroll bar is positioned between the buttons.
    self.scrollbar = UIScrollbar( self.ax, self.ay, self.w-1, 1, 1, self.h-2, self.h, contentHeight, self.scrollAreaHeight, function( noffset ) self:scroll( noffset ) end )
    self:addChild( self.scrollbar )
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function UIScrollArea:initialize( ox, oy, rx, ry, w, h, text, textHeight )
    UIElement.initialize( self, ox, oy, rx, ry, w, h )

    self.offset = 0
    self:setText( text, textHeight )
end

function UIScrollArea:draw()
    local tw, th = TexturePacks.getTileDimensions()

    love.graphics.setScissor( self.ax * tw, self.ay * th, self.w * tw, self.h * th )
    love.graphics.draw( self.text, self.ax * tw, (self.ay-self.offset) * th )
    love.graphics.setScissor()

    if self.scrollable then
        self.upButton:draw()
        self.downButton:draw()
        self.scrollbar:draw()
    end
end

function UIScrollArea:scroll( dir )
    if not self.scrollable then
        return
    end

    self.offset = self.offset + dir
    self.offset = math.max( 0, math.min( self.offset, self.scrollAreaHeight ))
    self.scrollbar:scroll( self.offset )
end

function UIScrollArea:setText( ntext, nheight )
    self.text = ntext

    local _, gh = TexturePacks.getGlyphDimensions()
    if math.floor( nheight / gh ) > self.h then
        createScrollbar( self, nheight )
    else
        self.scrollable = false
    end
end

function UIScrollArea:command( cmd, ... )
    if not self.scrollable then
        return
    end

    if cmd == 'scroll' then
        self:scroll( ... )
    end

    if self.upButton:isMouseOver() then
        self.upButton:command( cmd )
    elseif self.downButton:isMouseOver() then
        self.downButton:command( cmd )
    elseif self.scrollbar:isMouseOver() then
        self.scrollbar:command( cmd )
    end
end

return UIScrollArea
