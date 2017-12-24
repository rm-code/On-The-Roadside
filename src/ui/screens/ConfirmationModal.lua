---
-- This screen can be used to ask the user simple yes or no questions and
-- perform appropriate actions based on their choice.
-- @module ConfirmationModal
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Screen = require( 'src.ui.screens.Screen' )
local Translator = require( 'src.util.Translator' )
local UIOutlines = require( 'src.ui.elements.UIOutlines' )
local UIBackground = require( 'src.ui.elements.UIBackground' )
local UIHorizontalList = require( 'src.ui.elements.lists.UIHorizontalList' )
local UIButton = require( 'src.ui.elements.UIButton' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local GridHelper = require( 'src.util.GridHelper' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ConfirmationModal = Screen:subclass( 'ConfirmationModal' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local UI_GRID_WIDTH  = 20
local UI_GRID_HEIGHT = 10

local BUTTON_LIST_WIDTH = 20

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

---
-- Creates the yes and no button at the bottom of the screen.
-- @tparam  number           y             The origin of the screen along the y-axis.
-- @tparam  function         trueCallback  The function to call when the yes button is clicked.
-- @tparam  function         falseCallback The function to call when the no button is clicked.
-- @treturn UIHorizontalList               The button list.
--
local function createButtons( y, trueCallback, falseCallback )
    local lx = GridHelper.centerElement( BUTTON_LIST_WIDTH, 1 )
    local ly = y + UI_GRID_HEIGHT - 2

    local buttonList = UIHorizontalList( lx, ly, 0, 0, BUTTON_LIST_WIDTH, 1 )

    local buttonWidth = math.floor( BUTTON_LIST_WIDTH * 0.5 )

    local yesButton = UIButton( lx, ly, 0, 0, buttonWidth, 1, trueCallback, Translator.getText( 'ui_yes' ))
    buttonList:addChild( yesButton )

    local noButton = UIButton( lx, ly, 0, 0, buttonWidth, 1, falseCallback, Translator.getText( 'ui_no' ))
    buttonList:addChild( noButton )

    return buttonList
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

---
-- Initialises the ConfirmationModal.
-- @tparam string   text          The text to display inside of the modal.
-- @tparam function trueCallback  The function to call when the yes button is clicked.
-- @tparam function falseCallback The function to call when the no button is clicked.
--
function ConfirmationModal:initialize( text, trueCallback, falseCallback )
    self.text = text
    self.trueCallback = trueCallback
    self.falseCallback = falseCallback

    self.x, self.y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )

    self.background = UIBackground( self.x, self.y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )

    self.outlines = generateOutlines( self.x, self.y )
    self.buttonList = createButtons( self.y, self.trueCallback, self.falseCallback )
end

---
-- Draws the ConfirmationModal.
--
function ConfirmationModal:draw()
    self.background:draw()
    self.outlines:draw()
    self.buttonList:draw()

    local tw, th = TexturePacks.getTileDimensions()
    TexturePacks.setColor( 'ui_text' )
    love.graphics.printf( self.text, (self.x+2) * tw, (self.y+2) * th, (UI_GRID_WIDTH-4) * tw, 'center' )
    TexturePacks.resetColor()
end

---
-- Updates the ConfirmationModal.
--
function ConfirmationModal:update()
    self.buttonList:update()
end

---
-- Handle keypressed events.
--
function ConfirmationModal:keypressed( key, scancode )
    if key == 'escape' then
        self.falseCallback()
    end

    if scancode == 'left' then
        self.buttonList:command( 'left' )
    elseif scancode == 'right' then
        self.buttonList:command( 'right' )
    elseif scancode == 'return' then
        self.buttonList:command( 'activate' )
    end
end

---
-- Handle mousereleased events.
--
function ConfirmationModal:mousereleased()
    self.buttonList:command( 'activate' )
end

return ConfirmationModal
