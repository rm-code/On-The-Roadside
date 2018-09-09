---
-- @module UIBaseCharacterInfo
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UIElement = require( 'src.ui.elements.UIElement' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local Translator = require( 'src.util.Translator' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIBaseCharacterInfo = UIElement:subclass( 'UIBaseCharacterInfo' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local UI_GRID_WIDTH = 16
local UI_GRID_HEIGHT = 8

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

---
-- Adjusts colors based on how close a value is compared to its total.
-- @tparam number value The value to compare.
-- @tparam number total The maxium value.
-- @treturn table A table containing RGBA values.
--
local function adjustColors( value, total )
    local fraction = value / total
    if fraction < 0 then
        return TexturePacks.getColor( 'ui_path_ap_low' )
    elseif fraction <= 0.2 then
        return TexturePacks.getColor( 'ui_path_ap_med' )
    elseif fraction <= 0.6 then
        return TexturePacks.getColor( 'ui_path_ap_high' )
    elseif fraction <= 1.0 then
        return TexturePacks.getColor( 'ui_path_ap_full' )
    end
end

---
-- Draws general information about the character (name, class, type).
-- @tparam Text  textObject    The Text object to modify.
-- @tparam table colorTable    The table to use for adding colored text.
-- @tparam table characterInfo The table containing information about a character.
--
local function drawCharacterInfo( textObject, colorTable, character )
    local tw, th = TexturePacks.getTileDimensions()

    local x, y = 0, 0
    x = x + addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_text_dark' ), Translator.getText( 'ui_healthscreen_name' ))
    addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_character_name' ), character.name )

    x, y = 0, th
    x = x + addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_text_dark' ), Translator.getText( 'ui_class' ))
    addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_character_name' ), Translator.getText( character.class ))

    x, y =  8 * tw, th
    x = x + addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_text_dark' ), Translator.getText( 'ui_healthscreen_type' ))
    addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_character_name' ), Translator.getText( character.body.id ))
end

---
-- Draws the health points.
-- @tparam Text   textObject The Text object to modify.
-- @tparam table  colorTable The table to use for adding colored text.
-- @tparam number curHP      The health points to display.
-- @tparam number maxHP      The maximum health points to display.
--
local function drawHealthPoints( textObject, colorTable, curHP, maxHP )
    local tw, th = TexturePacks.getTileDimensions()

    local x, y = 0 * tw, 2 * th
    x = x + addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_text_dark' ), Translator.getText( 'ui_hp' ))
    x = x + addToTextObject( textObject, colorTable, x, y, adjustColors( curHP, maxHP ), curHP )
    x = x + addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_text_dark' ), '(' )
    x = x + addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_path_ap_full' ), maxHP )
    addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_text_dark' ), ')' )
end

---
-- Fills the text object to draw on the screen.
-- @tparam Text  textObject    The Text object to modify.
-- @tparam table colorTable    The table to use for adding colored text.
-- @tparam table characterInfo The table containing information about a character.
--
local function createText( textObject, colorTable, characterInfo )
    drawCharacterInfo( textObject, colorTable, characterInfo )
    drawHealthPoints( textObject, colorTable, characterInfo.body.currentHP, characterInfo.body.maximumHP )
end

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UIBaseCharacterInfo:initialize( ox, oy, rx, ry )
    UIElement.initialize( self, ox, oy, rx, ry, UI_GRID_WIDTH, UI_GRID_HEIGHT )

    self.textObject = love.graphics.newText( TexturePacks.getFont():get() )
    self.colorTable = {}
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function UIBaseCharacterInfo:draw()
    local tw, th = TexturePacks.getTileDimensions()

    love.graphics.draw( self.textObject, (self.ax+1) * tw, (self.ay+1) * th )
end

function UIBaseCharacterInfo:setCharacter( characterInfo )
    self.textObject:clear()
    createText( self.textObject, self.colorTable, characterInfo )
end

return UIBaseCharacterInfo
