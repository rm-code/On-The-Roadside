---
-- @module SavegameScreen
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Screen = require( 'src.ui.screens.Screen' )
local ScreenManager = require( 'lib.screenmanager.ScreenManager' )

local Translator = require( 'src.util.Translator' )
local SaveHandler = require( 'src.SaveHandler' )
local GridHelper = require( 'src.util.GridHelper' )

local UIMenuTitle = require( 'src.ui.elements.UIMenuTitle' )
local UICopyrightFooter = require( 'src.ui.elements.UICopyrightFooter' )
local UIContainer = require( 'src.ui.elements.UIContainer' )
local UIButton = require( 'src.ui.elements.UIButton' )
local UISaveGameEntry = require( 'src.savegames.UISaveGameEntry' )
local UISaveGameHeader = require( 'src.savegames.UISaveGameHeader' )
local UIPaginatedList = require( 'src.ui.elements.lists.UIPaginatedList' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local SavegameScreen = Screen:subclass( 'SavegameScreen' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local UI_GRID_WIDTH  = 64
local UI_GRID_HEIGHT = 48

local TITLE_POSITION = 2

local BACK_BUTTON_WIDTH = 10
local BACK_BUTTON_HEIGHT = 1
local BACK_BUTTON_OFFSET_Y = UI_GRID_HEIGHT - 3

local SAVEGAME_LIST_WIDTH = 42
local SAVEGAME_LIST_HEIGHT = 28
local SAVEGAME_LIST_OFFSET_Y = 16

local SAVEGAME_LIST_HEADER_OFFSET_Y = 14

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

local function createBackButton()
    local x, _ = GridHelper.centerElement( BACK_BUTTON_WIDTH, UI_GRID_HEIGHT )

    local function callback()
        ScreenManager.switch( 'mainmenu' )
    end
    return UIButton( x, BACK_BUTTON_OFFSET_Y, 0, 0, BACK_BUTTON_WIDTH, BACK_BUTTON_HEIGHT, callback, Translator.getText( 'ui_back' ))
end

---
-- Returns a list of all directories in the save directory sorted by their
-- last modification time.
-- @tparam string subdir The save directory to load from.
-- @tparam table A sorted sequence containing the name of each save folder.
--
local function loadFiles( savedir )
    local saveDirectories = {}

    for _, item in pairs( love.filesystem.getDirectoryItems( savedir )) do
        if love.filesystem.getInfo( savedir .. '/' .. item, 'directory' ) then
            saveDirectories[#saveDirectories + 1] = item
        end
    end

    table.sort( saveDirectories, function( a, b )
        return love.filesystem.getInfo( savedir .. '/' .. a ).modtime > love.filesystem.getInfo( savedir .. '/' .. b ).modtime
    end)

    return saveDirectories
end

local function createSaveGameList( self )
    local x, _ = GridHelper.centerElement( SAVEGAME_LIST_WIDTH, SAVEGAME_LIST_HEIGHT )
    local saveGameList = UIPaginatedList( x, SAVEGAME_LIST_OFFSET_Y, 0, 0, SAVEGAME_LIST_WIDTH, SAVEGAME_LIST_HEIGHT )

    local saves = {}

    local items = loadFiles( SaveHandler.getSaveFolder() )
    for i, folder in ipairs( items ) do
        local valid, version = SaveHandler.validateSave( folder )
        local type = Translator.getText( SaveHandler.loadSaveType( folder ).type )
        local date = os.date( '%Y-%m-%d %X', love.filesystem.getInfo( SaveHandler.getSaveFolder() .. '/' .. folder ).modtime )
        saves[i] = UISaveGameEntry( 0, 0, 0, 0, folder, version, date, type, valid )
        saves[i]:observe( self )
    end

    saveGameList:setItems( saves )

    return saveGameList
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function SavegameScreen:initialize()
    self.x, self.y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )

    self.container = UIContainer()

    self.backButton = createBackButton( self.x, self.y )
    self.saveGameList = createSaveGameList( self )

    self.container:register( self.saveGameList )
    self.container:register( self.backButton )

    self.title = UIMenuTitle( Translator.getText( 'ui_title_savegames' ), TITLE_POSITION )
    self.header = UISaveGameHeader( SAVEGAME_LIST_HEADER_OFFSET_Y )
    self.footer = UICopyrightFooter()
end

function SavegameScreen:receive( msg, ... )
    if msg == 'DELETE_SAVE' then
        local save = ...
        SaveHandler.deleteSave( save.name )
        self.saveGameList:removeItem( save )
    end
end

function SavegameScreen:update()
    self.container:update()
end

function SavegameScreen:draw()
    self.title:draw()
    self.header:draw()
    self.backButton:draw()
    self.saveGameList:draw()
    self.footer:draw()
end

function SavegameScreen:keypressed( _, scancode )
    love.mouse.setVisible( false )

    if scancode == 'escape' then
        ScreenManager.switch( 'mainmenu' )
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

function SavegameScreen:mousemoved()
    love.mouse.setVisible( true )
end

---
-- Handle mousereleased events.
--
function SavegameScreen:mousereleased()
    self.container:mousecommand( 'activate' )
end

function SavegameScreen:resize( _, _ )
    local x, _ = GridHelper.centerElement( SAVEGAME_LIST_WIDTH, SAVEGAME_LIST_HEIGHT )
    self.saveGameList:setOrigin( x, SAVEGAME_LIST_OFFSET_Y )

    x, _ = GridHelper.centerElement( BACK_BUTTON_WIDTH, UI_GRID_HEIGHT )
    self.backButton:setOrigin( x, BACK_BUTTON_OFFSET_Y )
end

return SavegameScreen
