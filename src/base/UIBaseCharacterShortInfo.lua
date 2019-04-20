---
-- @module UIBaseCharacterShortInfo
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local UIElement = require( 'src.ui.elements.UIElement' )
local UICheckBox = require( 'src.ui.elements.UICheckBox' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIBaseCharacterShortInfo = UIElement:subclass( 'UIBaseCharacterShortInfo' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local UI_GRID_WIDTH = 16
local UI_GRID_HEIGHT = 1

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
-- Draws the character's skill points.
-- @tparam Text      textObject The Text object to modify.
-- @tparam table     colorTable The table to use for adding colored text.
-- @tparam Character character  The character for which to create the information.
--
local function drawSkills( textObject, colorTable, character )
    local tw, _ = TexturePacks.getTileDimensions()
    addToTextObject( textObject, colorTable, tw * COLUMN_HP_X,  0, adjustColors( character:getCurrentHP(), character:getMaximumHP() ), character:getCurrentHP() )
    addToTextObject( textObject, colorTable, tw * COLUMN_AP_X,  0, adjustColors( character:getCurrentAP(), character:getMaximumAP() ), character:getCurrentAP() )
    addToTextObject( textObject, colorTable, tw * COLUMN_FIR_X, 0, adjustColors( character:getShootingSkill(), 120 ), character:getShootingSkill() )
    addToTextObject( textObject, colorTable, tw * COLUMN_THR_X, 0, adjustColors( character:getThrowingSkill(), 120 ), character:getThrowingSkill() )
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

function UIBaseCharacterShortInfo:initialize( ox, oy, rx, ry, character, recruitmentList )
    UIElement.initialize( self, ox, oy, rx, ry, UI_GRID_WIDTH, UI_GRID_HEIGHT )

    self.textObject = love.graphics.newText( TexturePacks.getFont():get() )
    self.colorTable = {}

    self.recruitmentList = recruitmentList
    self.character = character

    self.checkBox = UICheckBox( self.ax, self.ay, 0, 0, 10, 1, 'CHECK_BOX_CHECKED', 'CHECK_BOX_UNCHECKED', character:getName() )
    self.checkBox:observe( self )

    self:addChild( self.checkBox )

    createText( self.textObject, self.colorTable, character )
end

function UIBaseCharacterShortInfo:receive( msg )
    if msg == 'CHECK_BOX_CHECKED' then
        self.recruitmentList[self.character] = true
    elseif msg == 'CHECK_BOX_UNCHECKED' then
        self.recruitmentList[self.character] = nil
    end
end

function UIBaseCharacterShortInfo:draw()
    local tw, th = TexturePacks.getTileDimensions()

    love.graphics.draw( self.textObject, self.ax * tw, self.ay * th )
    self.checkBox:draw()
end

function UIBaseCharacterShortInfo:update()
    self.checkBox:update()
end

function UIBaseCharacterShortInfo:command( cmd )
    for i = 1, #self.children do
        self.children[i]:command( cmd )
    end
end

function UIBaseCharacterShortInfo:mousecommand( cmd )
    for i = 1, #self.children do
        if self.children[i]:isMouseOver() then
            self.children[i]:mousecommand( cmd )
            return
        end
    end
end

function UIBaseCharacterShortInfo:setFocus( focus )
    for i = 1, #self.children do
        self.children[i]:setFocus( focus )
    end
end

return UIBaseCharacterShortInfo
