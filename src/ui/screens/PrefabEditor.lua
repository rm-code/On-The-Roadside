---
-- @module PrefabEditor
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Screen = require( 'src.ui.screens.Screen' )
local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local TileFactory = require( 'src.map.tiles.TileFactory' )
local WorldObjectFactory = require( 'src.map.worldobjects.WorldObjectFactory' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local UIButton = require( 'src.ui.elements.UIButton' )
local Camera = require( 'src.ui.Camera' )
local Translator = require( 'src.util.Translator' )
local PrefabCanvas = require( 'src.ui.mapeditor.PrefabCanvas' )
local PrefabBrush = require( 'src.ui.mapeditor.PrefabBrush' )
local UIContainer = require( 'src.ui.elements.UIContainer' )
local GridHelper = require( 'src.util.GridHelper' )
local UIPaginatedList = require( 'src.ui.elements.lists.UIPaginatedList' )
local Settings = require( 'src.Settings' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local PrefabEditor = Screen:subclass( 'PrefabEditor' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local SELECTOR_WIDTH  = 10
local SELECTOR_HEIGHT = 10

local CANVAS_SIZES = {
    'XS',
    'S',
    'M',
    'L',
    'XL'
}
-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

local function createTileSelector( tileTemplates, tool )
    local lx, ly = 1, 1
    local tileSelector = UIPaginatedList( lx, ly, 0, 0, SELECTOR_WIDTH, SELECTOR_HEIGHT )

    local buttons = {}
    for id, template in pairs( tileTemplates ) do
        local function callback()
            tool:setBrush( template, 'tile' )
        end

        local button = UIButton( 0, 0, 0, 0, SELECTOR_WIDTH, 1, callback, Translator.getText( id ), 'left' )
        button:setIcon( id )
        button:setIconColorID( id )

        buttons[#buttons + 1] = button
    end

    tileSelector:setItems( buttons )

    return tileSelector
end

local function createWorldObjectSelector( objectTemplates, tool )
    local lx, ly = 1, SELECTOR_HEIGHT + 2
    local objectSelector = UIPaginatedList( lx, ly, 0, 0, SELECTOR_WIDTH, SELECTOR_HEIGHT )

    local buttons = {}
    for id, template in pairs( objectTemplates ) do
        local function callback()
            tool:setBrush( template, 'worldObject' )
        end

        local button = UIButton( 0, 0, 0, 0, SELECTOR_WIDTH, 1, callback, Translator.getText( id ), 'left' )
        if template.openable then
            button:setIcon( id, 'closed' )
        elseif template.connections then
            button:setIcon( id, 'default' )
        else
            button:setIcon( id )
        end
        button:setIconColorID( id )

        buttons[#buttons + 1] = button
    end

    objectSelector:setItems( buttons )

    return objectSelector
end

local function createCanvasSelector( canvas, camera )
    local lx, ly = 1, 2 * ( SELECTOR_HEIGHT + 2 )
    local canvasSelector = UIPaginatedList( lx, ly, 0, 0, SELECTOR_WIDTH, SELECTOR_HEIGHT )

    local buttons = {}
    for i = 1, #CANVAS_SIZES do
        local function callback()
            canvas:setSize( CANVAS_SIZES[i] )
            camera:setBounds( canvas:getWidth(), canvas:getHeight() )
        end

        buttons[#buttons + 1] = UIButton( 0, 0, 0, 0, SELECTOR_WIDTH, 1, callback, CANVAS_SIZES[i], 'left' )
    end

    canvasSelector:setItems( buttons )

    return canvasSelector
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function PrefabEditor:initialize()
    love.filesystem.createDirectory( 'mods/maps/prefabs' )
    love.mouse.setVisible( true )

    self.canvas = PrefabCanvas( 'XS' )

    self.camera = Camera( self.canvas:getWidth(), self.canvas:getHeight(), TexturePacks.getTileDimensions() )

    self.tool = PrefabBrush()

    local tileTemplates = TileFactory.getTemplates()
    self.tileSelector = createTileSelector( tileTemplates, self.tool )

    local objectTemplates = WorldObjectFactory.getTemplates()
    self.objectSelector = createWorldObjectSelector( objectTemplates, self.tool )

    self.canvasSelector = createCanvasSelector( self.canvas, self.camera )

    self.uiContainer = UIContainer()
    self.uiContainer:register( self.tileSelector )
    self.uiContainer:register( self.objectSelector )
    self.uiContainer:register( self.canvasSelector )
end

function PrefabEditor:receive( event, ... )
    if event == 'LOAD_LAYOUT' then
        self.canvas:load( ... )
    end
end

function PrefabEditor:draw()
    if not self:isActive() then
        return
    end

    self.tileSelector:draw()
    self.objectSelector:draw()
    self.canvasSelector:draw()

    self.camera:attach()
    self.canvas:draw()
    self.tool:draw()
    self.camera:detach()

    local  _, sh = GridHelper.getScreenGridDimensions()
    local tw, th = TexturePacks.getTileDimensions()

    local template, type = self.tool:getBrush()
    if template then
        love.graphics.print( string.format( 'Selected brush: %s (%s)', Translator.getText( template.id ), type ), tw, (sh-1) * th )
    end
end

function PrefabEditor:update( dt )
    if not self:isActive() then
        return
    end

    self.camera:update( dt )

    self.uiContainer:update()

    self.tool:setPosition( self.camera:getMouseWorldGridPosition() )
    self.tool:use( self.canvas, self.camera )
end

function PrefabEditor:keypressed( _, scancode )
    if scancode == 'escape' then
        ScreenManager.push( 'prefabeditormenu', self.canvas )
        return
    end

    local action = Settings.mapInput( Settings.INPUTLAYOUTS.PREFAB_EDITOR, scancode )

    if action == 'increase_tool_size' then
        self.tool:increase()
    elseif action == 'decrease_tool_size' then
        self.tool:decrease()
    end

    if action == 'mode_draw' then
        self.tool:setMode( 'draw' )
    elseif action == 'mode_erase' then
        self.tool:setMode( 'erase' )
    elseif action == 'mode_fill' then
        self.tool:setMode( 'fill' )
    end

    if action == 'hide_worldobjects' then
        self.canvas:toggleObjects()
    end

    if scancode == 'tab' then
        self.uiContainer:next()
    end

    if scancode == 'return' then
        self.uiContainer:command( 'activate' )
    end

    if self.uiContainer:hasFocus() then
        self.uiContainer:command( scancode )
    else
        self.camera:input( action, true )
    end
end

function PrefabEditor:keyreleased( _, scancode )
    self.camera:input( Settings.mapInput( Settings.INPUTLAYOUTS.PREFAB_EDITOR, scancode ), false )
end

function PrefabEditor:mousemoved()
    love.mouse.setVisible( true )
end

function PrefabEditor:mousepressed()
    self.uiContainer:mousecommand( 'activate' )
    self.tool:setActive( true )
end

function PrefabEditor:mousereleased()
    self.tool:setActive( false )
end

return PrefabEditor
