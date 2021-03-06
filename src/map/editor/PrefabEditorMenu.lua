---
-- @module PrefabEditorMenu
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Screen = require( 'src.ui.screens.Screen' )
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

local PrefabEditorMenu = Screen:subclass( 'PrefabEditorMenu' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local UI_GRID_WIDTH  = 14
local UI_GRID_HEIGHT = 7

local BUTTON_LIST_VERTICAL_OFFSET = 1

local SAVE_DIR = 'mods/maps/prefabs/'
local FILE_EXTENSION = '.prefab'

-- ------------------------------------------------
-- Private Methods
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

local function createSaveButton( lx, ly, canvas )
    local function savePrefab()
        local function confirmCallback( name )
            Log.debug( 'Saving a new prefab: ' .. name .. FILE_EXTENSION, 'PrefabEditorMenu' )

            -- Serialize the canvas and add the name as an ID.
            local t = canvas:serialize()
            t.id = name

            Compressor.save( t, SAVE_DIR .. name .. FILE_EXTENSION )
            ScreenManager.pop()
        end

        ScreenManager.push( 'inputdialog', Translator.getText( 'ui_prefabeditor_enter_name' ), false, confirmCallback )
    end

    return UIButton( lx, ly, 0, 0, UI_GRID_WIDTH, 1, savePrefab, Translator.getText( 'ui_prefabeditor_save' ))
end

local function loadPrefab()
    ScreenManager.push( 'editorloading', SAVE_DIR )
end

local function testMap()
    ScreenManager.pop()
    ScreenManager.push( 'maptest' )
end

local function createButtons( canvas )
    local lx, ly = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )
    local buttonList = UIVerticalList( lx, ly, 0, BUTTON_LIST_VERTICAL_OFFSET, UI_GRID_WIDTH, UI_GRID_HEIGHT )

    local savePrefabButton = createSaveButton( lx, ly, canvas )
    buttonList:addChild( savePrefabButton )

    local loadPrefabButton = UIButton( lx, ly, 0, 0, UI_GRID_WIDTH, 1, loadPrefab, Translator.getText( 'ui_prefabeditor_load' ))
    buttonList:addChild( loadPrefabButton )

    local testButton = UIButton( lx, ly, 0, 0, UI_GRID_WIDTH, 1, testMap, Translator.getText( 'ui_prefabeditor_test' ))
    buttonList:addChild( testButton )

    local switchButton = UIButton( lx, ly, 0, 0, UI_GRID_WIDTH, 1, function() ScreenManager.switch( 'mapeditor' ) end, Translator.getText( 'ui_prefabeditor_switch' ))
    buttonList:addChild( switchButton )

    local exitButton = UIButton( lx, ly, 0, 0, UI_GRID_WIDTH, 1, function() ScreenManager.switch( 'mainmenu' ) end, Translator.getText( 'general_exit' ))
    buttonList:addChild( exitButton )

    buttonList:setFocus( true )
    return buttonList
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function PrefabEditorMenu:initialize( canvas )
    self.x, self.y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )

    self.background = UIBackground( self.x, self.y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )
    self.outlines = generateOutlines( self.x, self.y )
    self.buttonList = createButtons( canvas )

    self.container = UIContainer()
    self.container:register( self.buttonList )
end

function PrefabEditorMenu:draw()
    if not self:isActive() then
        return
    end
    self.background:draw()
    self.outlines:draw()
    self.container:draw()
end

function PrefabEditorMenu:update()
    if not self:isActive() then
        return
    end
    self.container:update()
end

function PrefabEditorMenu:keypressed( _, scancode )
    love.mouse.setVisible( false )

    if scancode == 'escape' then
        ScreenManager.pop()
    end

    if scancode == 'up' then
        self.container:command( 'up' )
    elseif scancode == 'down' then
        self.container:command( 'down' )
    elseif scancode == 'return' then
        self.container:command( 'activate' )
    end
end

function PrefabEditorMenu:mousemoved()
    love.mouse.setVisible( true )
end

function PrefabEditorMenu:mousereleased()
    self.container:command( 'activate' )
end

function PrefabEditorMenu:resize( _, _ )
    self.x, self.y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )
    self.background:setOrigin( self.x, self.y )
    self.outlines:setOrigin( self.x, self.y )
    self.buttonList:setOrigin( self.x, self.y )
end

return PrefabEditorMenu
