---
-- @module UICharacterInfo
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UIElement = require( 'src.ui.elements.UIElement' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local Translator = require( 'src.util.Translator' )
local AttackInput = require( 'src.turnbased.helpers.AttackInput' )
local MovementInput = require( 'src.turnbased.helpers.MovementInput' )
local InteractionInput = require( 'src.turnbased.helpers.InteractionInput' )
local ExecutionState = require( 'src.turnbased.states.ExecutionState' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UICharacterInfo = UIElement:subclass( 'UICharacterInfo' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local UI_GRID_WIDTH = 16
local UI_GRID_HEIGHT = 8

local WEAPON_COLUMN_MODE    =  0
local WEAPON_COLUMN_AP      = 10
local WEAPON_COLUMN_ACC     = 15
local WEAPON_COLUMN_ATTACKS = 20

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

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
-- Returns the predicted cost for a particular action.
-- @tparam InputMode mode      The active input mode (movement, attack, ...).
-- @tparam Map       map       The game's map.
-- @tparam Camera    camera    The game's camera.
-- @tparam Character character The currently active character.
-- @treturn number The predicted AP cost for a certain action.
--
local function getActionCost( mode, map, camera, character )
    local tile = map:getTileAt( camera:getMouseWorldGridPosition() )
    if not tile then
        return
    end

    if mode:isInstanceOf( AttackInput ) then
        return mode:getPredictedAPCost( character )
    elseif mode:isInstanceOf( InteractionInput ) then
        return mode:getPredictedAPCost( tile, character )
    elseif mode:isInstanceOf( MovementInput ) and mode:hasPath() then
        return mode:getPredictedAPCost()
    end
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
-- @tparam Character character  The currently active character.
--
local function drawCharacterInfo( textObject, colorTable, character )
    local x, y = 0, 0
    x = x + addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_text_dark' ), Translator.getText( 'ui_healthscreen_name' ))
    addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_character_name' ), character:getName() )

    x, y = 0, 16
    x = x + addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_text_dark' ), Translator.getText( 'ui_class' ))
    addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_character_name' ), Translator.getText( character:getCreatureClass() ))
end

---
-- Draws the action point indicator. If the player planning mode is active it
-- also draws the predicted costs for any action planned by the player.
-- @tparam Text      textObject The Text object to modify.
-- @tparam table     colorTable The table to use for adding colored text.
-- @tparam TurnState state      The current state (execution or planning).
-- @tparam Map       map        The game's map.
-- @tparam Camera    camera     The game's camera.
-- @tparam Character character  The currently active character.

local function drawActionPoints( textObject, colorTable, state, map, camera, character )
    local currentActionPoints = character:getCurrentAP()
    local maximumActionPoints = character:getMaximumAP()

    local x, y = 0, 32
    -- AP:
    x = x + addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_text_dark' ), Translator.getText( 'ui_ap' ))
    -- AP: xx
    x = x + addToTextObject( textObject, colorTable, x, y, adjustColors( currentActionPoints, maximumActionPoints ), currentActionPoints )

    -- The cost display should only be displayed during the planning state.
    if state:isInstanceOf( ExecutionState ) then
        return
    end

    -- Add the resulting action points.
    local cost = getActionCost( state:getInputMode(), map, camera, character )
    if not cost then
        return
    end

    -- AP: xx =>
    x = x + addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_text' ), ' => ' )
    -- AP: xx => yy
    addToTextObject( textObject, colorTable, x, y, adjustColors( character:getCurrentAP() - cost, character:getMaximumAP() ), character:getCurrentAP() - cost )
end

---
-- Draws the action point indicator. If the player planning mode is active it
-- also draws the predicted costs for any action planned by the player.
-- @tparam Text      textObject The Text object to modify.
-- @tparam table     colorTable The table to use for adding colored text.
-- @tparam Character character  The currently active character.

local function drawHealthPoints( textObject, colorTable, character )
    local currentHealthPoints = character:getCurrentHP()
    local maximumHealthPoints = character:getMaximumHP()

    local x, y = 112, 32
    -- HP:
    x = x + addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_text_dark' ), Translator.getText( 'ui_hp' ))
    -- HP: xx
    addToTextObject( textObject, colorTable, x, y, adjustColors( currentHealthPoints, maximumHealthPoints ), currentHealthPoints )
end

---
-- Draws the name of the weapon a character has currently equipped.
-- @tparam Text   textObject The Text object to modify.
-- @tparam table  colorTable The table to use for adding colored text.
-- @tparam Weapon weapon     The equipped weapon.
--
local function drawWeaponName( textObject, colorTable, weapon )
    local x, y = 0, 48
    x = x + addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_text_dark' ), Translator.getText( 'ui_weapon' ))
    addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_text' ), Translator.getText( weapon:getID() ))
end

---
-- Draws ammunition info about the equipped weapon (only if it is reloadable).
-- @tparam Text      textObject The Text object to modify.
-- @tparam table     colorTable The table to use for adding colored text.
-- @tparam Weapon    weapon     The equipped weapon.
--
local function drawAmmunitionInfo( textObject, colorTable, weapon )
    -- If the weapon is reloadable we show the current ammo in the magazine,
    -- the maximum capacity of the magazine and the total amount of ammo
    -- on the character.
    if not weapon:isReloadable() then
        return
    end

    local x, y = 0, 64
    local currentCapacity = weapon:getCurrentCapacity()
    local maximumCapacity = weapon:getMaximumCapacity()
    local text = string.format( '%d/%d', currentCapacity, maximumCapacity )

    x = x + addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_text_dark' ), Translator.getText( 'ui_ammo' ))
    addToTextObject( textObject, colorTable, x, y, TexturePacks.getColor( 'ui_text' ), text )
end

---
-- Draws the stats for the currently selected weapon mode.
-- @tparam Text  textObject The Text object to modify.
-- @tparam table colorTable The table to use for adding colored text.
-- @tparam table mode       The currently selected weapon mode.
--
local function drawWeaponMode( textObject, colorTable, mode, dmg )
    local tw, _ = TexturePacks.getGlyphDimensions()
    local y = 80
    addToTextObject( textObject, colorTable, WEAPON_COLUMN_MODE    * tw, y, TexturePacks.getColor( 'ui_text_dark' ), 'MODE' )
    addToTextObject( textObject, colorTable, WEAPON_COLUMN_AP      * tw, y, TexturePacks.getColor( 'ui_text_dark' ), 'AP'   )
    addToTextObject( textObject, colorTable, WEAPON_COLUMN_ACC     * tw, y, TexturePacks.getColor( 'ui_text_dark' ), 'ACC'  )
    addToTextObject( textObject, colorTable, WEAPON_COLUMN_ATTACKS * tw, y, TexturePacks.getColor( 'ui_text_dark' ), 'DMG'  )

    y = 96
    addToTextObject( textObject, colorTable, WEAPON_COLUMN_MODE    * tw, y, TexturePacks.getColor( 'ui_text' ), mode.name     )
    addToTextObject( textObject, colorTable, WEAPON_COLUMN_AP      * tw, y, TexturePacks.getColor( 'ui_text' ), mode.cost     )
    addToTextObject( textObject, colorTable, WEAPON_COLUMN_ACC     * tw, y, TexturePacks.getColor( 'ui_text' ), mode.accuracy )
    addToTextObject( textObject, colorTable, WEAPON_COLUMN_ATTACKS * tw, y, TexturePacks.getColor( 'ui_text' ), string.format( '%dx%d', mode.attacks, dmg ))
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function UICharacterInfo:initialize( ox, oy )
    UIElement.initialize( self, ox, oy, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )

    self.textObject = love.graphics.newText( TexturePacks.getFont():get() )
    self.colorTable = {}
end

function UICharacterInfo:draw()
    local tw, th = TexturePacks.getTileDimensions()

    love.graphics.draw( self.textObject, (self.ax+1) * tw, (self.ay+1) * th )
end

function UICharacterInfo:update( state, map, camera, character )
    self.textObject:clear()

    drawCharacterInfo( self.textObject, self.colorTable, character )
    drawActionPoints( self.textObject, self.colorTable, state, map, camera, character )
    drawHealthPoints( self.textObject, self.colorTable, character )

    if not character:getWeapon() then
        return
    end

    drawWeaponName( self.textObject, self.colorTable, character:getWeapon() )
    drawAmmunitionInfo( self.textObject, self.colorTable, character:getWeapon() )
    drawWeaponMode( self.textObject, self.colorTable, character:getWeapon():getAttackMode(), character:getWeapon():getDamage() )
end

return UICharacterInfo
