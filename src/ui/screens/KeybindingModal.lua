---
-- This screen can be used to inform the user of certain events.
-- @module KeybindingModal
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local Screen = require( 'src.ui.screens.Screen' )
local UIOutlines = require( 'src.ui.elements.UIOutlines' )
local UIBackground = require( 'src.ui.elements.UIBackground' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local GridHelper = require( 'src.util.GridHelper' )
local Translator = require( 'src.util.Translator' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local KeybindingModal = Screen:subclass( 'KeybindingModal' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local UI_GRID_WIDTH  = 20
local UI_GRID_HEIGHT = 10

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
-- Initialises the KeybindingModal.
-- @tparam string mode
-- @tparam string action
--
function KeybindingModal:initialize( mode, action )
    self.mode = mode
    self.action = action

    self.x, self.y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )

    self.background = UIBackground( self.x, self.y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )

    self.outlines = generateOutlines( self.x, self.y )
end

---
-- Draws the KeybindingModal.
--
function KeybindingModal:draw()
    self.background:draw()
    self.outlines:draw()

    local tw, th = TexturePacks.getTileDimensions()
    TexturePacks.setColor( 'ui_text' )
    love.graphics.printf( Translator.getText( 'ui_enter_key' ), (self.x+2) * tw, (self.y+2) * th, (UI_GRID_WIDTH-4) * tw, 'center' )
    TexturePacks.resetColor()
end

---
-- Handle keyreleased events.
--
function KeybindingModal:keypressed( _, scancode )
    if scancode == 'escape' then
        ScreenManager.pop()
        return
    end

    ScreenManager.publish( 'CHANGED_KEYBINDING', scancode, self.mode, self.action )
    ScreenManager.pop()
end

return KeybindingModal
