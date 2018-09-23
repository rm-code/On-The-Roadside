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
local DataHandler = require( 'src.DataHandler' )

local UIContainer = require( 'src.ui.elements.UIContainer' )
local UIBackground = require( 'src.ui.elements.UIBackground' )
local UIOutlines = require( 'src.ui.elements.UIOutlines' )
local UIPaginatedList = require( 'src.ui.elements.lists.UIPaginatedList' )
local UIBaseCharacterInfo = require( 'src.base.UIBaseCharacterInfo' )
local UIButton = require( 'src.ui.elements.UIButton' )
local UIObservableButton = require( 'src.ui.elements.UIObservableButton' )

local Log = require( 'src.util.Log' )

local Faction = require( 'src.characters.Faction' )
local Inventory = require( 'src.inventory.Inventory' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BaseScreen = Screen:subclass( 'BaseScreen' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FACTIONS = require( 'src.constants.FACTIONS' )
local STANCES = require( 'src.constants.STANCES' )

local UI_GRID_WIDTH  = 64
local UI_GRID_HEIGHT = 48

local CHARACTER_LIST_WIDTH = 25
local CHARACTER_LIST_HEIGHT = 15
local CHARACTER_LIST_OFFSET_X = 1
local CHARACTER_LIST_OFFSET_Y = 1

local RECRUITMENT_BUTTON_WIDTH = 8
local RECRUITMENT_BUTTON_HEIGHT = 1
local RECRUITMENT_BUTTON_OFFSET_X = 1
local RECRUITMENT_BUTTON_OFFSET_Y = UI_GRID_HEIGHT - 2

local INVENTORY_BUTTON_WIDTH = 8
local INVENTORY_BUTTON_HEIGHT = 1
local INVENTORY_BUTTON_OFFSET_X = RECRUITMENT_BUTTON_WIDTH + RECRUITMENT_BUTTON_OFFSET_X + 1
local INVENTORY_BUTTON_OFFSET_Y = UI_GRID_HEIGHT - 2

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
-- @tparam self The BaseScreen instance to use.
-- @treturn UIPaginatedList The paginated list instance.
--
local function createCharacterList( self )
    local buttonList = UIPaginatedList( self.x, self.y, CHARACTER_LIST_OFFSET_X, CHARACTER_LIST_OFFSET_Y, CHARACTER_LIST_WIDTH, CHARACTER_LIST_HEIGHT )

    local characterList = {}

    self.faction:iterate( function( character )
        local button = UIObservableButton( 0, 0, 0, 0, CHARACTER_LIST_WIDTH, 1, character:getName(), 'left', 'CHARACTER_BUTTON_CLICKED', character )
        button:observe( self )
        characterList[#characterList + 1] = button
    end)

    buttonList:setItems( characterList )

    return buttonList
end

---
-- Creates a button which allows the user to start a new combat mission.
-- @tparam  number   x       The parent's absolute coordinates along the x-axis.
-- @tparam  number   y       The parent's absolute coordinates along the y-axis.
-- @tparam  Faction  faction The Faction to use for the next mission.
-- @treturn UIButton         The newly created UIButton.
--
local function createNextMissionButton( x, y, faction )
    -- The function to call when the button is activated.
    local function callback()
        DataHandler.copyPlayerFaction( faction:serialize() )
        ScreenManager.switch( 'combat' )
    end

    -- Create the UIButton.
    local rx, ry, w, h = NEXTMISSION_BUTTON_OFFSET_X, NEXTMISSION_BUTTON_OFFSET_Y, NEXTMISSION_BUTTON_WIDTH, NEXTMISSION_BUTTON_HEIGHT
    return UIButton( x, y, rx, ry, w, h, callback, Translator.getText( 'base_next_mission' ))
end

---
-- Creates a button which allows the user to edit a character's inventory
-- @tparam self The BaseScreen instance to use
-- @treturn UIObservableButton The newly created UIObservableButton.
--
local function createInventoryButton( self )
    local rx, ry, w, h = INVENTORY_BUTTON_OFFSET_X, INVENTORY_BUTTON_OFFSET_Y, INVENTORY_BUTTON_WIDTH, INVENTORY_BUTTON_HEIGHT
    local button = UIObservableButton( self.x, self.y, rx, ry, w, h, Translator.getText( 'ui_base_inventory' ), 'left', 'INVENTORY_BUTTON_CLICKED' )
    button:observe( self )
    return button
end

---
-- Creates a button which allows the user to open the recruitment screen.
-- @tparam  number   x       The parent's absolute coordinates along the x-axis.
-- @tparam  number   y       The parent's absolute coordinates along the y-axis.
-- @tparam  Faction  faction The Faction to use for the next mission.
-- @treturn UIButton         The newly created UIButton.
--
local function createRecruitmentButton( x, y, faction )
    -- The function to call when the button is activated.
    local function callback()
        DataHandler.copyPlayerFaction( faction:serialize() )
        ScreenManager.switch( 'recruitment' )
    end

    -- Create the UIButton.
    local rx, ry, w, h = RECRUITMENT_BUTTON_OFFSET_X, RECRUITMENT_BUTTON_OFFSET_Y, RECRUITMENT_BUTTON_WIDTH, RECRUITMENT_BUTTON_HEIGHT
    return UIButton( x, y, rx, ry, w, h, callback, Translator.getText( 'base_recruitment_button' ))
end


---
-- Cleans the character data for the next mission and removes dead characters.
-- @tparam  table factionData The data to clean.
-- @treturn table             The cleaned character data.
--
local function cleanUpFactionData( factionData )
    -- Remove dead characters from the faction data.
    for i = #factionData, 1, -1 do
        local character = factionData[i]
        if character.body.currentHP <= 0 then
            Log.debug( string.format( 'Removed dead character "%s" from faction.', character.name ), 'BaseScreen' )
            table.remove( factionData, i )
        end
    end

    -- Reset the living characters for the next mission.
    for _, character in ipairs( factionData ) do
        character.x, character.y = nil, nil
        character.body.currentHP = character.body.maximumHP
        character.currentAP = character.maximumAP
        character.stance = STANCES.STAND
    end
    return factionData
end

---
-- Creates a proper Faction object based on the faction data.
-- @tparam  table   factionData The faction data to use to create the faction.
-- @treturn Faction             The created Faction.
--
local function createFaction( factionData )
    local faction = Faction( FACTIONS.ALLIED, false )
    faction:loadCharacters( factionData )
    return faction
end

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function BaseScreen:initialize()
    self.x, self.y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )

    local factionData = cleanUpFactionData( DataHandler.pastePlayerFaction() )
    self.faction = createFaction( factionData )

    self.baseInventory = Inventory()

    self.outlines = generateOutlines( self.x, self.y )
    self.background = UIBackground( self.x, self.y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )
    self.uiBaseCharacterInfo = UIBaseCharacterInfo( self.x, self.y, CHARACTER_LIST_WIDTH, 0 )

    -- Initialize the character info with the first character.
    self.character = self.faction:getFirstCharacter()
    self.uiBaseCharacterInfo:setCharacter( self.character )

    self.container = UIContainer()
    self.characterList = createCharacterList( self )
    self.nextMissionButton = createNextMissionButton( self.x, self.y, self.faction )
    self.inventoryButton = createInventoryButton( self )
    self.recruitmentButton = createRecruitmentButton( self.x, self.y, self.faction )

    self.container:register( self.characterList )
    self.container:register( self.nextMissionButton )
    self.container:register( self.inventoryButton )
    self.container:register( self.recruitmentButton )
end

function BaseScreen:receive( msg, ... )
    if msg == 'CHARACTER_BUTTON_CLICKED' then
        self.character = ...
        self.uiBaseCharacterInfo:setCharacter( self.character )
        return
    end
    if msg == 'INVENTORY_BUTTON_CLICKED' then
        ScreenManager.push( 'inventory', self.character, 'inventory_base', self.baseInventory )
        return
    end
end

function BaseScreen:update()
    self.container:update()
end

function BaseScreen:draw()
    self.background:draw()
    self.outlines:draw()

    self.characterList:draw()
    self.uiBaseCharacterInfo:draw()

    self.nextMissionButton:draw()
    self.inventoryButton:draw()
    self.recruitmentButton:draw()
end

function BaseScreen:resize()
    self.x, self.y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )

    self.background:setOrigin( self.x, self.y )
    self.outlines:setOrigin( self.x, self.y )
    self.characterList:setOrigin( self.x, self.y )
    self.uiBaseCharacterInfo:setOrigin( self.x, self.y )
    self.nextMissionButton:setOrigin( self.x, self.y )
    self.inventoryButton:setOrigin( self.x, self.y )
    self.recruitmentButton:setOrigin( self.x, self.y )
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

    if scancode == 'escape' then
        ScreenManager.push( 'basemenu', self.faction )
    end
end

function BaseScreen:mousereleased()
    self.container:mousecommand( 'activate' )
end

function BaseScreen:mousemoved()
    love.mouse.setVisible( true )
end

return BaseScreen
