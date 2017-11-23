---
-- @module EditorLoadingScreen
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Screen = require( 'lib.screenmanager.Screen' )
local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local GridHelper = require( 'src.util.GridHelper' )
local UIOutlines = require( 'src.ui.elements.UIOutlines' )
local UIBackground = require( 'src.ui.elements.UIBackground' )
local UIVerticalList = require( 'src.ui.elements.lists.UIVerticalList' )
local UIButton = require( 'src.ui.elements.UIButton' )
local UIContainer = require( 'src.ui.elements.UIContainer' )
local Compressor = require( 'src.util.Compressor' )
local Util = require( 'src.util.Util' )
local Log = require( 'src.util.Log' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local EditorLoadingScreen = {}

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
-- Constructor
-- ------------------------------------------------

function EditorLoadingScreen.new()
    local self = Screen.new()

    -- ------------------------------------------------
    -- Private Variables
    -- ------------------------------------------------

    local buttonList

    local background
    local outlines
    local x, y

    local uiContainer

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    ---
    -- Generates the outlines for this screen.
    --
    local function generateOutlines()
        outlines = UIOutlines( x, y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )

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
    end

    local function isValidFile( path )
        if not love.filesystem.isFile( path ) then
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

        buttonList = UIVerticalList( lx, ly, 0, BUTTON_LIST_VERTICAL_OFFSET, UI_GRID_WIDTH, 1 )

        -- Create entries for last five savegames.
        local items = love.filesystem.getDirectoryItems( directory )
        for i = 1, #items do
            if isValidFile( directory .. items[i] ) then
                buttonList:addChild( createListEntry( lx, ly, items[i], directory ))
            end
        end

        buttonList:setFocus( true )
    end


    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init( directory )
        x, y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )
        background = UIBackground( x, y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )

        generateOutlines()
        createButtons( directory )

        uiContainer = UIContainer()
        uiContainer:register( buttonList )
    end

    function self:update()
        uiContainer:update()
    end

    function self:draw()
        background:draw()
        outlines:draw()
        uiContainer:draw()
    end

    function self:keypressed( _, scancode )
        if scancode == 'escape' then
            ScreenManager.pop()
        end

        if scancode == 'up' then
            uiContainer:command( 'up' )
        elseif scancode == 'down' then
            uiContainer:command( 'down' )
        elseif scancode == 'return' then
            uiContainer:command( 'activate' )
        end
    end

    function self:mousemoved()
        love.mouse.setVisible( true )
    end

    function self:mousereleased()
        uiContainer:command( 'activate' )
    end

    function self:resize( _, _ )
        x, y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )
        background:setOrigin( x, y )
        outlines:setOrigin( x, y )
        buttonList:setOrigin( x, y )
    end

    return self
end

return EditorLoadingScreen
