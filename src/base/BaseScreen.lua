---
-- @module BaseScreen
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local Screen = require( 'src.ui.screens.Screen' )

local Translator = require( 'src.util.Translator' )
local GridHelper = require( 'src.util.GridHelper' )
local SaveHandler = require( 'src.SaveHandler' )

local UIContainer = require( 'src.ui.elements.UIContainer' )
local UIBackground = require( 'src.ui.elements.UIBackground' )
local UIOutlines = require( 'src.ui.elements.UIOutlines' )
local UIPaginatedList = require( 'src.ui.elements.lists.UIPaginatedList' )
local UIBaseCharacterInfo = require( 'src.base.UIBaseCharacterInfo' )
local UIButton = require( 'src.ui.elements.UIButton' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BaseScreen = Screen:subclass( 'BaseScreen' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local UI_GRID_WIDTH  = 64
local UI_GRID_HEIGHT = 48

local CHARACTER_LIST_WIDTH = 25
local CHARACTER_LIST_HEIGHT = 15
local CHARACTER_LIST_OFFSET_X = 1
local CHARACTER_LIST_OFFSET_Y = 1

local QUIT_BUTTON_WIDTH = 4
local QUIT_BUTTON_HEIGHT = 1
local QUIT_BUTTON_OFFSET_X = 1
local QUIT_BUTTON_OFFSET_Y = UI_GRID_HEIGHT - 2

local NEXTMISSION_BUTTON_WIDTH = 8
local NEXTMISSION_BUTTON_HEIGHT = 1
local NEXTMISSION_BUTTON_OFFSET_X = UI_GRID_WIDTH - NEXTMISSION_BUTTON_WIDTH - 2
local NEXTMISSION_BUTTON_OFFSET_Y = UI_GRID_HEIGHT - 2

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Creates the outlines for this screen.
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
-- Creates a paginated list for all the player's characters.
-- @tparam  number          x             The origin of the screen along the x-axis.
-- @tparam  number          y             The origin of the screen along the y-axis.
-- @tparam  table           factionData   The data about the player's faction and characters.
-- @tparam  table           characterInfo The table containing information about a character.
-- @treturn UIPaginatedList               The paginated list instance.

local function createCharacterList( x, y, factionData, uiBaseCharacterInfo )
    local buttonList = UIPaginatedList( x, y, CHARACTER_LIST_OFFSET_X, CHARACTER_LIST_OFFSET_Y, CHARACTER_LIST_WIDTH, CHARACTER_LIST_HEIGHT )

    local characterList = {}
    for i = 1, #factionData do
        local function callback()
            uiBaseCharacterInfo:setCharacter( factionData[i] )
        end
        characterList[i] = UIButton( 0, 0, 0, 0, CHARACTER_LIST_WIDTH, 1, callback, factionData[i].name, 'left' )
    end

    buttonList:setItems( characterList )

    return buttonList
end

---
-- Creates a button which allows the user to return to the main menu.
-- @tparam  number   x The parent's absolute coordinates along the x-axis.
-- @tparam  number   y The parent's absolute coordinates along the y-axis.
-- @treturn UIButton   The newly created UIButton.
--
local function createQuitButton( x, y )
    -- The function to call when the button is activated.
    local function callback()
        ScreenManager.switch( 'mainmenu' )
    end

    -- Create the UIButton.
    local rx, ry, w, h = QUIT_BUTTON_OFFSET_X, QUIT_BUTTON_OFFSET_Y, QUIT_BUTTON_WIDTH, QUIT_BUTTON_HEIGHT
    return UIButton( x, y, rx, ry, w, h, callback, Translator.getText( 'general_exit' ))
end

---
-- Creates a button which allows the user to start a new combat mission.
-- @tparam  number   x The parent's absolute coordinates along the x-axis.
-- @tparam  number   y The parent's absolute coordinates along the y-axis.
-- @treturn UIButton   The newly created UIButton.
--
local function createNextMissionButton( x, y, factionData )
    -- The function to call when the button is activated.
    local function callback()
        SaveHandler.copyPlayerFaction( factionData )
        ScreenManager.switch( 'combat' )
    end

    -- Create the UIButton.
    local rx, ry, w, h = NEXTMISSION_BUTTON_OFFSET_X, NEXTMISSION_BUTTON_OFFSET_Y, NEXTMISSION_BUTTON_WIDTH, NEXTMISSION_BUTTON_HEIGHT
    return UIButton( x, y, rx, ry, w, h, callback, Translator.getText( 'base_next_mission' ))
end

---
-- Clean the character data for the next mission.
-- @tparam  table factionData The data to clean.
-- @treturn table             The cleaned character data.
--
local function cleanUpFactionData( factionData )
    for _, character in ipairs( factionData ) do
        character.x, character.y = nil, nil
        character.body.currentHP = character.body.maximumHP
        character.actionPoints = character.maxActionPoints
    end
    return factionData
end

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function BaseScreen:initialize()
    self.x, self.y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )

    self.factionData = cleanUpFactionData( SaveHandler.pastePlayerFaction() )

    self.outlines = generateOutlines( self.x, self.y )
    self.background = UIBackground( self.x, self.y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )
    self.uiBaseCharacterInfo = UIBaseCharacterInfo( self.x, self.y, CHARACTER_LIST_WIDTH, 0 )

    self.container = UIContainer()
    self.characterList = createCharacterList( self.x, self.y, self.factionData, self.uiBaseCharacterInfo )
    self.quitButton = createQuitButton( self.x, self.y )
    self.nextMissionButton = createNextMissionButton( self.x, self.y, self.factionData )

    self.container:register( self.characterList )
    self.container:register( self.quitButton )
    self.container:register( self.nextMissionButton )
end

function BaseScreen:update()
    self.container:update()
end

function BaseScreen:draw()
    self.background:draw()
    self.outlines:draw()

    self.characterList:draw()
    self.uiBaseCharacterInfo:draw()

    self.quitButton:draw()
    self.nextMissionButton:draw()
end

function BaseScreen:resize()
    self.x, self.y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )

    self.background:setOrigin( self.x, self.y )
    self.outlines:setOrigin( self.x, self.y )
end

function BaseScreen:keypressed( _, scancode )
    love.mouse.setVisible( false )

    if scancode == 'tab' then
        self.container:next()
    end

    if scancode == 'up' then
        self.container:command( 'up' )
    elseif scancode == 'down' then
        self.container:command( 'down' )
    elseif scancode == 'left' then
        self.container:command( 'left' )
    elseif scancode == 'right' then
        self.container:command( 'right' )
    elseif scancode == 'return' then
        self.container:command( 'activate' )
    end
end

function BaseScreen:mousereleased()
    self.container:mousecommand( 'activate' )
end

return BaseScreen
