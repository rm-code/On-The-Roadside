---
-- @module PlayerInfo
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local Screen = require( 'src.ui.screens.Screen' )
local Translator = require( 'src.util.Translator' )
local UIOutlines = require( 'src.ui.elements.UIOutlines' )
local UIBackground = require( 'src.ui.elements.UIBackground' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local GridHelper = require( 'src.util.GridHelper' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local PlayerInfo = Screen:subclass( 'PlayerInfo' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local UI_GRID_WIDTH  = 30
local UI_GRID_HEIGHT = 16

local NAME_POSITION = 0
local CLASS_POSITION = 16
local TYPE_POSITION = 32

local AP_POSITION = { X =  0, Y = 2 }
local HP_POSITION = { X = 16, Y = 2 }

local STATUS_POSITION = { X = 0, Y = 4 }

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
        outlines:add( ox, 2                ) -- Header
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
-- @tparam Text      textObject The Text object to modify.
-- @tparam table     colorTable The table to use for adding colored text.
-- @tparam number gw The glyph width to use for modifying the text offset.
-- @tparam number gh The glyph height to use for modifying the text offset.
-- @tparam Character character  The currently active character.
--
local function drawCharacterInfo( textObject, colorTable, gw, _, character )
    local x, y = NAME_POSITION * gw, 0
    x = x + addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_text_dark' ), Translator.getText( 'ui_healthscreen_name' ))
    addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_character_name' ), character:getName() )

    x, y = CLASS_POSITION * gw, 0
    x = x + addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_text_dark' ), Translator.getText( 'ui_class' ))
    addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_character_name' ), Translator.getText( character:getCreatureClass() ))

    x, y = TYPE_POSITION * gw, 0
    x = x + addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_text_dark' ), Translator.getText( 'ui_healthscreen_type' ))
    addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_character_name' ), Translator.getText( character:getBody():getID() ))
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
-- @tparam Text      textObject The Text object to modify.
-- @tparam table     colorTable The table to use for adding colored text.
-- @tparam number gw The glyph width to use for modifying the text offset.
-- @tparam number gh The glyph height to use for modifying the text offset.
-- @tparam Character character  The currently active character.
--
local function drawActionPoints( textObject, colorTable, gw, gh, character )
    local currentActionPoints = character:getCurrentAP()
    local maximumActionPoints = character:getMaximumAP()

    local x, y = AP_POSITION.X * gw, AP_POSITION.Y * gh
    -- AP:
    x = x + addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_text_dark' ), Translator.getText( 'ui_ap' ))
    -- AP: xx
    x = x + addToTextObject( textObject, colorTable, x, y, adjustColors( currentActionPoints, maximumActionPoints ), currentActionPoints )
    -- AP: xx/
    x = x + addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_text' ), '/' )
    -- AP: xx/yy
    addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_text' ), maximumActionPoints )
end

---
-- @tparam Text      textObject The Text object to modify.
-- @tparam table     colorTable The table to use for adding colored text.
-- @tparam number gw The glyph width to use for modifying the text offset.
-- @tparam number gh The glyph height to use for modifying the text offset.
-- @tparam Character character  The currently active character.
--
local function drawHealthPoints( textObject, colorTable, gw, gh, character )
    local currentHealthPoints = character:getCurrentHP()
    local maximumHealthPoints = character:getMaximumHP()

    local x, y = HP_POSITION.X * gw, HP_POSITION.Y * gh
    -- HP:
    x = x + addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_text_dark' ), Translator.getText( 'ui_hp' ))
    -- HP: xx
    x = x + addToTextObject( textObject, colorTable, x, y, adjustColors( currentHealthPoints, maximumHealthPoints ), currentHealthPoints )
    -- HP: xx/
    x = x + addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_text' ), '/' )
    -- HP: xx/yy
    addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_text' ), maximumHealthPoints )
end

---
-- @tparam Text      textObject The Text object to modify.
-- @tparam table     colorTable The table to use for adding colored text.
-- @tparam number gw The glyph width to use for modifying the text offset.
-- @tparam number gh The glyph height to use for modifying the text offset.
-- @tparam Character character  The currently active character.
--
local function drawStatusEffects( textObject, colorTable, gw, gh, character )

    local str = ''
    for status, _ in pairs( character:getBody():getStatusEffects():getActiveEffects() ) do
        str = str .. Translator.getText( status ) .. ', '
    end

    -- Remove last comma.
    str = str:sub( 1, -3 )

    local x, y = STATUS_POSITION.X * gw, STATUS_POSITION.Y * gh
    x = x + addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_text_dark' ), Translator.getText( 'ui_healthscreen_status' ))
    addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_text' ), str )
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function PlayerInfo:initialize( character )
    self.x, self.y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )

    self.background = UIBackground( self.x, self.y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )
    self.outlines = generateOutlines( self.x, self.y )

    self.textObject = love.graphics.newText( TexturePacks.getFont():get() )
    self.colorTable = {}

    self.character = character
end

function PlayerInfo:draw()
    self.background:draw()
    self.outlines:draw()

    local tw, th = TexturePacks.getTileDimensions()
    love.graphics.draw( self.textObject, (self.x+1) * tw, (self.y+1) * th )

    TexturePacks.resetColor()
end

function PlayerInfo:update()
    self.textObject:clear()

    local gw, gh = TexturePacks.getGlyphDimensions()
    drawCharacterInfo( self.textObject, self.colorTable, gw, gh, self.character )
    drawActionPoints( self.textObject, self.colorTable, gw, gh, self.character )
    drawHealthPoints( self.textObject, self.colorTable, gw, gh, self.character )
    drawStatusEffects( self.textObject, self.colorTable, gw, gh, self.character )
end

function PlayerInfo:keypressed( key )
    if key == 'escape' or key == 'h' then
        ScreenManager.pop()
    end
end

return PlayerInfo
