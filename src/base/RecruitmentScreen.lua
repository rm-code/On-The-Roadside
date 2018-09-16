---
-- @module RecruitmentScreen
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local Screen = require( 'src.ui.screens.Screen' )

local Translator = require( 'src.util.Translator' )
local GridHelper = require( 'src.util.GridHelper' )
local DataHandler = require( 'src.DataHandler' )

local UIContainer = require( 'src.ui.elements.UIContainer' )
local UIBackground = require( 'src.ui.elements.UIBackground' )
local UIOutlines = require( 'src.ui.elements.UIOutlines' )
local UIPaginatedList = require( 'src.ui.elements.lists.UIPaginatedList' )
local UIBaseCharacterShortInfo = require( 'src.base.UIBaseCharacterShortInfo' )
local UIBaseCharacterShortInfoHeader = require( 'src.base.UIBaseCharacterShortInfoHeader' )
local UIButton = require( 'src.ui.elements.UIButton' )

local CharacterFactory = require( 'src.characters.CharacterFactory' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local RecruitmentScreen = Screen:subclass( 'RecruitmentScreen' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local UI_GRID_WIDTH  = 27
local UI_GRID_HEIGHT = 30

local CHARACTER_LIST_HEADER_X = 1
local CHARACTER_LIST_HEADER_Y = 1

local CHARACTER_LIST_WIDTH = 25
local CHARACTER_LIST_HEIGHT = 25
local CHARACTER_LIST_OFFSET_X = 1
local CHARACTER_LIST_OFFSET_Y = 3

local CHARACTER_AMOUNT = 48

local HIRE_BUTTON_WIDTH = 8
local HIRE_BUTTON_HEIGHT = 1
local HIRE_BUTTON_OFFSET_X = UI_GRID_WIDTH - HIRE_BUTTON_WIDTH - 2
local HIRE_BUTTON_OFFSET_Y = UI_GRID_HEIGHT - 2

local CANCEL_BUTTON_WIDTH = 8
local CANCEL_BUTTON_HEIGHT = 1
local CANCEL_BUTTON_OFFSET_X = 1
local CANCEL_BUTTON_OFFSET_Y = UI_GRID_HEIGHT - 2

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
-- Creates a paginated list for all the recruitable characters.
-- @tparam number x The origin of the screen along the x-axis.
-- @tparam number y The origin of the screen along the y-axis.
-- @tparam table recruitmentList This list will be populated by the selected recruits.
-- @treturn UIPaginatedList The paginated list instance.

local function createRecruitList( x, y, recruitmentList )
    local buttonList = UIPaginatedList( x, y, CHARACTER_LIST_OFFSET_X, CHARACTER_LIST_OFFSET_Y, CHARACTER_LIST_WIDTH, CHARACTER_LIST_HEIGHT )

    local characterList = {}

    for i = 1, CHARACTER_AMOUNT do
        characterList[i] = UIBaseCharacterShortInfo( 0, 0, 0, 0, CharacterFactory.newCharacter( 'allied' ), recruitmentList )
    end

    buttonList:setItems( characterList )

    return buttonList
end

---
-- Creates a button which copies the new recruits to the faction data and switches
-- back to the base screen.
-- @tparam number x The origin of the screen along the x-axis.
-- @tparam number y The origin of the screen along the y-axis.
-- @tparam table recruitmentList This list will be populated by the selected recruits.
-- @treturn UIPaginatedList The paginated list instance.

local function createHireButton( x, y, recruitmentList )
    -- The function to call when the button is activated.
    local function callback()
        local factionData = DataHandler.pastePlayerFaction()

        for recruit, _ in pairs( recruitmentList) do
            factionData[#factionData + 1] = recruit:serialize()
        end

        DataHandler.copyPlayerFaction( factionData )
        ScreenManager.switch( 'base' )
    end

    -- Create the UIButton.
    local rx, ry, w, h = HIRE_BUTTON_OFFSET_X, HIRE_BUTTON_OFFSET_Y, HIRE_BUTTON_WIDTH, HIRE_BUTTON_HEIGHT
    return UIButton( x, y, rx, ry, w, h, callback, Translator.getText( 'recruitment_hire_button' ))
end

---
-- Creates a button which allows the user to return to the base menu.
-- @tparam number lx The parent's absolute coordinates along the x-axis.
-- @tparam number ly The parent's absolute coordinates along the y-axis.
-- @treturn UIButton The newly created UIButton.
--
local function createCancelButton( lx, ly )
    -- The function to call when the button is activated.
    local function callback()
        ScreenManager.switch( 'base' )
    end

    -- Create the UIButton.
    local rx, ry, w, h = CANCEL_BUTTON_OFFSET_X, CANCEL_BUTTON_OFFSET_Y, CANCEL_BUTTON_WIDTH, CANCEL_BUTTON_HEIGHT
    return UIButton( lx, ly, rx, ry, w, h, callback, Translator.getText( 'general_cancel' ))
end

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function RecruitmentScreen:initialize()
    self.x, self.y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )

    self.outlines = generateOutlines( self.x, self.y )
    self.background = UIBackground( self.x, self.y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )

    self.container = UIContainer()
    self.recruitmentList = {}
    self.recruits = createRecruitList( self.x, self.y, self.recruitmentList )

    self.header = UIBaseCharacterShortInfoHeader( self.x, self.y, CHARACTER_LIST_HEADER_X, CHARACTER_LIST_HEADER_Y )
    self.hireButton = createHireButton( self.x, self.y, self.recruitmentList )
    self.cancelButton = createCancelButton( self.x, self.y )

    self.container:register( self.recruits )
    self.container:register( self.hireButton )
    self.container:register( self.cancelButton )
end

function RecruitmentScreen:update()
    self.container:update()
end

function RecruitmentScreen:draw()
    self.background:draw()
    self.outlines:draw()

    self.recruits:draw()
    self.hireButton:draw()
    self.cancelButton:draw()

    self.header:draw()
end

function RecruitmentScreen:keypressed( _, scancode )
    love.mouse.setVisible( false )

    if scancode == 'escape' then
        ScreenManager.switch( 'base' )
        return
    end

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

function RecruitmentScreen:mousereleased()
    self.container:mousecommand( 'activate' )
end

function RecruitmentScreen:mousemoved()
    love.mouse.setVisible( true )
end

return RecruitmentScreen
