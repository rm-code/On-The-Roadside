---
-- @module PrefabEditorMenu
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
local Bitser = require( 'lib.Bitser' )
local Log = require( 'src.util.Log' )
local UIContainer = require( 'src.ui.elements.UIContainer' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local PrefabEditorMenu = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local UI_GRID_WIDTH  = 14
local UI_GRID_HEIGHT = 7

local BUTTON_LIST_VERTICAL_OFFSET = 1

local SAVE_DIR = 'mods/maps/prefabs/'
local FILE_EXTENSION = '.prefab'

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function PrefabEditorMenu.new()
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
            Log.debug( 'Saving a new prefab: ' .. name .. FILE_EXTENSION, 'PrefabEditorMenu' )

            -- Serialize the canvas and add the name as an ID.
            local t = canvas:serialize()
            t.id = name

            Bitser.dumpLoveFile( SAVE_DIR .. name .. FILE_EXTENSION, t )
            ScreenManager.pop()
        end

        ScreenManager.push( 'inputdialog', Translator.getText( 'ui_prefabeditor_enter_name' ), '', confirmCallback )
    end

    local function loadPrefab()
        ScreenManager.push( 'editorloading', SAVE_DIR )
    end

    local function testMap()
        ScreenManager.pop()
        ScreenManager.push( 'maptest' )
    end

    local function createButtons()
        local lx, ly = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )

        buttonList = UIVerticalList( lx, ly, 0, BUTTON_LIST_VERTICAL_OFFSET, UI_GRID_WIDTH, UI_GRID_HEIGHT )

        local savePrefabButton = UIButton( lx, ly, 0, 0, UI_GRID_WIDTH, 1, savePrefab, Translator.getText( 'ui_prefabeditor_save' ))
        buttonList:addChild( savePrefabButton )

        local loadPrefabButton = UIButton( lx, ly, 0, 0, UI_GRID_WIDTH, 1, loadPrefab, Translator.getText( 'ui_prefabeditor_load' ))
        buttonList:addChild( loadPrefabButton )

        local testButton = UIButton( lx, ly, 0, 0, UI_GRID_WIDTH, 1, testMap, Translator.getText( 'ui_prefabeditor_test' ))
        buttonList:addChild( testButton )

        local switchButton = UIButton( lx, ly, 0, 0, UI_GRID_WIDTH, 1, function() ScreenManager.switch( 'mapeditor' ) end, Translator.getText( 'ui_prefabeditor_switch' ))
        buttonList:addChild( switchButton )

        local exitButton = UIButton( lx, ly, 0, 0, UI_GRID_WIDTH, 1, function() ScreenManager.switch( 'mainmenu' ) end, Translator.getText( 'ui_prefabeditor_exit' ))
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

return PrefabEditorMenu
