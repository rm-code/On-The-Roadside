---
-- @module SavegameScreen
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Screen = require( 'src.ui.screens.Screen' )
local Translator = require( 'src.util.Translator' )
local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local SaveHandler = require( 'src.SaveHandler' )
local UICopyrightFooter = require( 'src.ui.elements.UICopyrightFooter' )
local UIVerticalList = require( 'src.ui.elements.lists.UIVerticalList' )
local UIButton = require( 'src.ui.elements.UIButton' )
local GridHelper = require( 'src.util.GridHelper' )
local UIContainer = require( 'src.ui.elements.UIContainer' )
local Util = require( 'src.util.Util' )
local UIMenuTitle = require( 'src.ui.elements.UIMenuTitle' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local SavegameScreen = Screen:subclass( 'SavegameScreen' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TITLE_POSITION = 2
local BUTTON_LIST_WIDTH = 20
local BUTTON_LIST_Y = 20

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

local function createBackButton( lx, ly )
    local function callback()
        ScreenManager.switch( 'mainmenu' )
    end
    return UIButton( lx, ly, 0, 0, BUTTON_LIST_WIDTH, 1, callback, Translator.getText( 'ui_back' ))
end

local function createSaveGameEntry( lx, ly, index, item, folder )
    local valid, version = SaveHandler.validateSave( folder )

    -- Generate the string for the savegame button showing the name of the saves,
    -- the version of the game at which they were created and their creation date.
    local str = string.format( '%2d. %s', index, item )
    str = Util.rightPadString( str, 36, ' ')
    str = str .. string.format( '  %s    %s', version, os.date( '%Y-%m-%d  %X', love.filesystem.getInfo( folder ).modtime ))

    local function callback()
        if valid then
            ScreenManager.switch( 'gamescreen', SaveHandler.load( folder ))
        end
    end

    local button = UIButton( lx, ly, 0, 0, BUTTON_LIST_WIDTH, 1, callback, str, 'center' )
    button:setActive( valid )
    return button
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

local function createButtons()
    local lx = GridHelper.centerElement( BUTTON_LIST_WIDTH, 1 )
    local ly = BUTTON_LIST_Y

    local buttonList = UIVerticalList( lx, ly, 0, 0, BUTTON_LIST_WIDTH, 1 )

    local items = loadFiles( SaveHandler.getSaveFolder() )
    local counter = 0
    for i = 1, #items do
        counter = counter + 1
        buttonList:addChild( createSaveGameEntry( lx, ly, counter, items[i], SaveHandler.getSaveFolder() .. '/' .. items[i] ))
    end

    buttonList:addChild( createBackButton( lx, ly ))
    return buttonList
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function SavegameScreen:initialize()
    self.title = UIMenuTitle( Translator.getText( 'ui_title_savegames'), TITLE_POSITION )
    self.buttonList = createButtons()

    self.container = UIContainer()
    self.container:register( self.buttonList )

    self.footer = UICopyrightFooter()
end

function SavegameScreen:update()
    self.container:update()
end

function SavegameScreen:draw()
    self.title:draw()
    self.container:draw()
    self.footer:draw()
end

function SavegameScreen:keypressed( _, scancode )
    love.mouse.setVisible( false )

    if scancode == 'escape' then
        ScreenManager.switch( 'mainmenu' )
    end

    if scancode == 'up' then
        self.container:command( 'up' )
    elseif scancode == 'down' then
        self.container:command( 'down' )
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
    local lx = GridHelper.centerElement( BUTTON_LIST_WIDTH, 1 )
    local ly = BUTTON_LIST_Y
    self.buttonList:setOrigin( lx, ly )
end

return SavegameScreen
