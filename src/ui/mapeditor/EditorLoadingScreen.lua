---
-- @module EditorLoadingScreen
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Screen = require( 'src.ui.screens.Screen' )
local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local GridHelper = require( 'src.util.GridHelper' )
local UIOutlines = require( 'src.ui.elements.UIOutlines' )
local UIBackground = require( 'src.ui.elements.UIBackground' )
local UIVerticalList = require( 'src.ui.elements.lists.UIVerticalList' )
local UIButton = require( 'src.ui.elements.UIButton' )
local UIContainer = require( 'src.ui.elements.UIContainer' )
local Compressor = require( 'src.util.Compressor' )
local Translator = require( 'src.util.Translator' )
local Util = require( 'src.util.Util' )
local Log = require( 'src.util.Log' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local EditorLoadingScreen = Screen:subclass( 'EditorLoadingScreen' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local UI_GRID_WIDTH  = 20
local UI_GRID_HEIGHT = 20

local BUTTON_LIST_VERTICAL_OFFSET = 1

local FILE_EXTENSIONS = {
    PREFAB = '.prefab',
    LAYOUT = '.layout'
}

-- ------------------------------------------------
-- Private Functions
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

local function isValidFile( path )
    if not love.filesystem.getInfo( path, 'file' ) then
        return
    end

    local extension = Util.getFileExtension( path )
    if extension == FILE_EXTENSIONS.LAYOUT or extension == FILE_EXTENSIONS.PREFAB then
        return true
    end
    Log.warn( string.format( 'Ignoring invalid file extension: "%s".', extension ), 'EditorLoadingScreen' )
end

local function createListEntry( lx, ly, item, folder )
    local function callback()
        ScreenManager.publish( 'LOAD_LAYOUT', Compressor.load( folder .. item ))
        ScreenManager.pop()
        ScreenManager.pop()
    end

    return UIButton( lx, ly, 0, 0, UI_GRID_WIDTH, 1, callback, item )
end

local function createButtons( directory )
    local lx, ly = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )
    local buttonList = UIVerticalList( lx, ly, 0, BUTTON_LIST_VERTICAL_OFFSET, UI_GRID_WIDTH, 1 )

    -- Create entries for last five savegames.
    local items = love.filesystem.getDirectoryItems( directory )
    for i = 1, #items do
        if isValidFile( directory .. items[i] ) then
            buttonList:addChild( createListEntry( lx, ly, items[i], directory ))
        end
    end

    local resumeButton = UIButton( lx, ly, 0, 0, UI_GRID_WIDTH, 1, function() ScreenManager.pop() end, Translator.getText( 'ui_back' ))
    buttonList:addChild( resumeButton )

    buttonList:setFocus( true )
    return buttonList
end


-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function EditorLoadingScreen:initialize( directory )
    self.x, self.y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )
    self.background = UIBackground( self.x, self.y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )

    self.outlines = generateOutlines( self.x, self.y )
    self.buttonList = createButtons( directory )

    self.uiContainer = UIContainer()
    self.uiContainer:register( self.buttonList )
end

function EditorLoadingScreen:update()
    self.uiContainer:update()
end

function EditorLoadingScreen:draw()
    self.background:draw()
    self.outlines:draw()
    self.uiContainer:draw()
end

function EditorLoadingScreen:keypressed( _, scancode )
    if scancode == 'escape' then
        ScreenManager.pop()
    end

    if scancode == 'up' then
        self.uiContainer:command( 'up' )
    elseif scancode == 'down' then
        self.uiContainer:command( 'down' )
    elseif scancode == 'return' then
        self.uiContainer:command( 'activate' )
    end
end

function EditorLoadingScreen:mousemoved()
    love.mouse.setVisible( true )
end

function EditorLoadingScreen:mousereleased()
    self.uiContainer:command( 'activate' )
end

function EditorLoadingScreen:resize( _, _ )
    self.x, self.y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )
    self.background:setOrigin( self.x, self.y )
    self.outlines:setOrigin( self.x, self.y )
    self.buttonList:setOrigin( self.x, self.y )
end

return EditorLoadingScreen
