---
-- @module UIBaseCharacterShortInfo
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UIElement = require( 'src.ui.elements.UIElement' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIBaseCharacterShortInfo = UIElement:subclass( 'UIBaseCharacterShortInfo' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local UI_GRID_WIDTH = 16
local UI_GRID_HEIGHT = 1

local COLUMN_NAME_X = 0
local COLUMN_AP_X   = 16
local COLUMN_HP_X   = 18
local COLUMN_FIR_X  = 20
local COLUMN_THR_X  = 22

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Adds colored text to the text object and returns the width of the added item.
-- @tparam Text   textObject The Text object to modify.
-- @tparam table  colorTable The table to use for adding colored text.
-- @tparam number y          The position at which to add the text along the x-axis.
-- @tparam number x          The position at which to add the text along the y-axis.
-- @tparam table  color      A table containing RGBA values.
-- @tparam string text       The text string to add.
-- @treturn number The width of the added text item.
--
local function addToTextObject( textObject, colorTable, x, y, color, text )
    colorTable[1], colorTable[2] = color, text
    textObject:add( colorTable, x, y )
    return textObject:getDimensions()
end

local function drawSkills( textObject, colorTable )
    local tw, _ = TexturePacks.getTileDimensions()
    addToTextObject( textObject, colorTable, tw * COLUMN_NAME_X,  0, TexturePacks.getColor( 'ui_character_name' ), 'NAME' )
    addToTextObject( textObject, colorTable, tw * COLUMN_HP_X,    0, TexturePacks.getColor( 'ui_character_name' ), 'HP' )
    addToTextObject( textObject, colorTable, tw * COLUMN_AP_X,    0, TexturePacks.getColor( 'ui_character_name' ), 'AP' )
    addToTextObject( textObject, colorTable, tw * COLUMN_FIR_X,   0, TexturePacks.getColor( 'ui_character_name' ), 'FIR' )
    addToTextObject( textObject, colorTable, tw * COLUMN_THR_X,   0, TexturePacks.getColor( 'ui_character_name' ), 'THR' )
end

---
-- Fills the text object to draw on the screen.
-- @tparam Text      textObject The Text object to modify.
-- @tparam table     colorTable The table to use for adding colored text.
-- @tparam Character character  The character for which to create the information.
--
local function createText( textObject, colorTable, character )
    drawSkills( textObject, colorTable, character )
end

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UIBaseCharacterShortInfo:initialize( ox, oy, rx, ry, character )
    UIElement.initialize( self, ox, oy, rx, ry, UI_GRID_WIDTH, UI_GRID_HEIGHT )

    self.textObject = love.graphics.newText( TexturePacks.getFont():get() )
    self.colorTable = {}

    createText( self.textObject, self.colorTable, character )
end


function UIBaseCharacterShortInfo:draw()
    local tw, th = TexturePacks.getTileDimensions()

    love.graphics.draw( self.textObject, self.ax * tw, self.ay * th )
end

return UIBaseCharacterShortInfo
