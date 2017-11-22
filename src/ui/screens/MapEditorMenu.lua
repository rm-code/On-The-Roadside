---
-- @module MapEditorMenu
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Screen = require( 'lib.screenmanager.Screen' )
local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local Translator = require( 'src.util.Translator' )
local UIOutlines = require( 'src.ui.elements.UIOutlines' )
local UIBackground = require( 'src.ui.elements.UIBackground' )
local UIVerticalList = require( 'src.ui.elements.lists.UIVerticalList' )
local UIButton = require( 'src.ui.elements.UIButton' )
local GridHelper = require( 'src.util.GridHelper' )
local Compressor = require( 'src.util.Compressor' )
local Log = require( 'src.util.Log' )
local UIContainer = require( 'src.ui.elements.UIContainer' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MapEditorMenu = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local UI_GRID_WIDTH  = 14
local UI_GRID_HEIGHT = 7

local BUTTON_LIST_VERTICAL_OFFSET = 1

local SAVE_DIR = 'mods/maps/layouts/'
local FILE_EXTENSION = '.layout'

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function MapEditorMenu.new()
    local self = Screen.new()

    -- ------------------------------------------------
    -- Private Variables
    -- ------------------------------------------------

    local buttonList
    local container

    local background
    local outlines
    local x, y

    local canvas

    -- ------------------------------------------------
    -- Private Methods
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

    local function savePrefab()
        local function confirmCallback( name )
            Log.debug( 'Saving a new layout: ' .. name .. FILE_EXTENSION, 'MapEditorMenu' )
            local t = canvas:getGrid()
            Compressor.save( t, SAVE_DIR .. name .. FILE_EXTENSION )
            ScreenManager.pop()
        end

        ScreenManager.push( 'inputdialog', Translator.getText( 'ui_mapeditor_enter_name' ), '', confirmCallback )
    end

    local function loadPrefab()
        ScreenManager.push( 'editorloading', SAVE_DIR )
    end

    local function testMap()
        ScreenManager.pop()
        ScreenManager.push( 'maptest', canvas:getGrid() )
    end

    local function createButtons()
        local lx, ly = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )

        buttonList = UIVerticalList( lx, ly, 0, BUTTON_LIST_VERTICAL_OFFSET, UI_GRID_WIDTH, UI_GRID_HEIGHT )

        local savePrefabButton = UIButton( lx, ly, 0, 0, UI_GRID_WIDTH, 1, savePrefab, Translator.getText( 'ui_mapeditor_save' ))
        buttonList:addChild( savePrefabButton )

        local loadPrefabButton = UIButton( lx, ly, 0, 0, UI_GRID_WIDTH, 1, loadPrefab, Translator.getText( 'ui_mapeditor_load' ))
        buttonList:addChild( loadPrefabButton )

        local testButton = UIButton( lx, ly, 0, 0, UI_GRID_WIDTH, 1, testMap, Translator.getText( 'ui_mapeditor_test' ))
        buttonList:addChild( testButton )

        local switchButton = UIButton( lx, ly, 0, 0, UI_GRID_WIDTH, 1, function() ScreenManager.switch( 'prefabeditor' ) end, Translator.getText( 'ui_mapeditor_switch' ))
        buttonList:addChild( switchButton )

        local exitButton = UIButton( lx, ly, 0, 0, UI_GRID_WIDTH, 1, function() ScreenManager.switch( 'mainmenu' ) end, Translator.getText( 'ui_mapeditor_exit' ))
        buttonList:addChild( exitButton )

        buttonList:setFocus( true )
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init( ncanvas )
        canvas = ncanvas

        x, y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )

        background = UIBackground( x, y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )
        generateOutlines()
        createButtons()

        container = UIContainer()
        container:register( buttonList )
    end

    function self:draw()
        if not self:isActive() then
            return
        end
        background:draw()
        outlines:draw()
        container:draw()
    end

    function self:update()
        if not self:isActive() then
            return
        end
        container:update()
    end

    function self:keypressed( _, scancode )
        love.mouse.setVisible( false )
        if scancode == 'escape' then
            ScreenManager.pop()
        end

        if scancode == 'up' then
            container:command( 'up' )
        elseif scancode == 'down' then
            container:command( 'down' )
        elseif scancode == 'return' then
            container:command( 'activate' )
        end
    end

    function self:mousemoved()
        love.mouse.setVisible( true )
    end

    function self:mousereleased()
        container:command( 'activate' )
    end

    function self:resize( _, _ )
        x, y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )
        background:setOrigin( x, y )
        outlines:setOrigin( x, y )
        buttonList:setOrigin( x, y )
    end

    return self
end

return MapEditorMenu
