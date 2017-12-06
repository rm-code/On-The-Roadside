---
-- @module InputDialog
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Screen = require( 'src.ui.screens.Screen' )
local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local UIOutlines = require( 'src.ui.elements.UIOutlines' )
local UIBackground = require( 'src.ui.elements.UIBackground' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local GridHelper = require( 'src.util.GridHelper' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local InputDialog = Screen:subclass( 'InputDialog' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local UI_GRID_WIDTH  = 20
local UI_GRID_HEIGHT = 6

local MAX_ENTRY_LENGTH = (UI_GRID_WIDTH - 4) * 2

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Generates the outlines for this screen.
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

    -- Vertical outlines.
    for oy = 0, UI_GRID_HEIGHT-1 do
        outlines:add( 0,               oy ) -- Left
        outlines:add( UI_GRID_WIDTH-1, oy ) -- Right
    end

    outlines:refresh()
    return outlines
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Initialises the ConfirmationModal.
--
function InputDialog:initialize( text, template, confirmCallback )
    self.timer = 0

    self.text = text
    self.entry = template or ''
    self.deleteAll = template and true or false

    self.confirmCallback = confirmCallback

    self.x, self.y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )
    self.background = UIBackground( self.x, self.y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )
    self.outlines = generateOutlines( self.x, self.y )
end

function InputDialog:update( dt )
    self.timer = self.timer + dt

    if self.timer > 0.5 then
        self.showCursor = not self.showCursor
        self.timer = 0
    end
end

---
-- Draws the ConfirmationModal.
--
function InputDialog:draw()
    local tw, th = TexturePacks.getTileDimensions()

    self.background:draw()
    self.outlines:draw()

    -- Draw the instructions.
    TexturePacks.setColor( 'ui_text' )
    love.graphics.printf( self.text, (self.x+1) * tw, (self.y+1) * th, (UI_GRID_WIDTH-2) * tw, 'left' )

    -- Draw the entered text.
    TexturePacks.setColor( 'ui_text_dark' )
    love.graphics.printf( self.entry, (self.x+2) * tw, (self.y+3) * th, (UI_GRID_WIDTH-4) * tw, 'left' )

    if self.showCursor and #self.entry < MAX_ENTRY_LENGTH then
        TexturePacks.setColor( 'ui_text_dark' )
        love.graphics.print( '_', (self.x+2) * tw + TexturePacks.getFont():measureWidth( self.entry ), (self.y+3) * th )
    end

    TexturePacks.resetColor()
end

---
-- Handle keypressed events.
--
function InputDialog:keypressed( _, scancode )
    if scancode == 'escape' then
        ScreenManager.pop()
    elseif scancode == 'return' then
        self.confirmCallback( self.entry )
    end

    if scancode == 'backspace' then
        if self.deleteAll then
            self.entry = ''
        else
            self.entry = self.entry:sub( 1, #self.entry-1 )
        end
    end
end

---
-- Handle textinput events.
--
function InputDialog:textinput( character )
    local c = character:match( '[%w_]' )
    if c and #self.entry < MAX_ENTRY_LENGTH then
        self.entry = self.entry .. c
    end
end

return InputDialog
