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
local PrefabCanvas = require( 'src.map.editor.PrefabCanvas' )
local DrawingTool = require( 'src.map.editor.DrawingTool' )
local FillingTool = require( 'src.map.editor.FillingTool' )
local EraserTool = require( 'src.map.editor.EraserTool' )
local UIContainer = require( 'src.ui.elements.UIContainer' )
local UIPaginatedList = require( 'src.ui.elements.lists.UIPaginatedList' )
local Settings = require( 'src.Settings' )
local GridHelper = require( 'src.util.GridHelper' )
local Brush = require( 'src.map.editor.Brush' )
local UIBackground = require( 'src.ui.elements.UIBackground' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local PrefabEditor = Screen:subclass( 'PrefabEditor' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local SELECTOR_WIDTH  = 10
local SELECTOR_HEIGHT = 10

local UI_BACKGROUND_WIDTH = 12

local CANVAS_SIZES = {
    'XS',
    'S',
    'M',
    'L',
    'XL'
}

-- ------------------------------------------------
-- Private Variables
-- ------------------------------------------------

local icons

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

local function cacheIcons( worldObjectTemplates )
    local nicons = {}
    for id, template in pairs( worldObjectTemplates ) do
        if template.openable then
            nicons[id] = { id, 'closed' }
        elseif template.connections then
            nicons[id] = { id, 'default' }
        else
            nicons[id] = { id }
        end
    end
    return nicons
end

local function createTileSelector( tileTemplates, brush )
    local lx, ly = 1, 1
    local tileSelector = UIPaginatedList( lx, ly, 0, 0, SELECTOR_WIDTH, SELECTOR_HEIGHT )

    local buttons = {}
    for id, template in pairs( tileTemplates ) do
        local function callback()
            brush:setTemplate( template )
            brush:setLayer( 'tile' )
            brush:setIcon( id )
            brush:setIconColorID( id )
        end

        local button = UIButton( 0, 0, 0, 0, SELECTOR_WIDTH, 1, callback, Translator.getText( id ), 'left' )
        button:setIcon( id )
        button:setIconColorID( id )
        button.sortCategories = { name = Translator.getText( id )}

        buttons[#buttons + 1] = button
    end

    tileSelector:setItems( buttons )
    tileSelector:sort( false, 'name' )

    return tileSelector
end

local function createWorldObjectSelector( objectTemplates, brush )
    local lx, ly = 1, SELECTOR_HEIGHT + 2
    local objectSelector = UIPaginatedList( lx, ly, 0, 0, SELECTOR_WIDTH, SELECTOR_HEIGHT )

    local buttons = {}
    for id, template in pairs( objectTemplates ) do
        local function callback()
            brush:setTemplate( template )
            brush:setLayer( 'worldObject' )
            brush:setIcon( unpack( icons[id] ))
            brush:setIconColorID( id )
        end

        local button = UIButton( 0, 0, 0, 0, SELECTOR_WIDTH, 1, callback, Translator.getText( id ), 'left' )
        button:setIcon( unpack( icons[id] ))
        button:setIconColorID( id )
        button.sortCategories = { name = Translator.getText( id )}

        buttons[#buttons + 1] = button
    end

    objectSelector:setItems( buttons )
    objectSelector:sort( false, 'name' )

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
    icons = cacheIcons( WorldObjectFactory.getTemplates() )

    love.filesystem.createDirectory( 'mods/maps/prefabs' )
    love.mouse.setVisible( true )

    self.canvas = PrefabCanvas( 'XS' )

    self.camera = Camera( self.canvas:getWidth(), self.canvas:getHeight(), TexturePacks.getTileDimensions() )

    self.brush = Brush()
    self.tool = DrawingTool()

    local tileTemplates = TileFactory.getTemplates()
    self.tileSelector = createTileSelector( tileTemplates, self.brush )

    local objectTemplates = WorldObjectFactory.getTemplates()
    self.objectSelector = createWorldObjectSelector( objectTemplates, self.brush )

    self.canvasSelector = createCanvasSelector( self.canvas, self.camera )

    local _, sh = GridHelper.getScreenGridDimensions()
    self.background = UIBackground( 0, 0, 0, 0, UI_BACKGROUND_WIDTH, sh )

    self.uiContainer = UIContainer()
    self.uiContainer:register( self.tileSelector )
    self.uiContainer:register( self.objectSelector )
    self.uiContainer:register( self.canvasSelector )
end

function PrefabEditor:receive( event, ... )
    if event == 'LOAD_LAYOUT' then
        self.canvas:deserialize( ... )
        self.camera:setBounds( self.canvas:getWidth(), self.canvas:getHeight() )
    end
end

function PrefabEditor:draw()
    if not self:isActive() then
        return
    end

    self.camera:attach()
    self.canvas:draw()
    self.tool:draw()
    self.camera:detach()

    self.background:draw()
    self.tileSelector:draw()
    self.objectSelector:draw()
    self.canvasSelector:draw()

    local  _, sh = GridHelper.getScreenGridDimensions()
    local tw, th = TexturePacks.getTileDimensions()

    local template, type = self.brush:getTemplate(), self.brush:getLayer()
    if template then
        TexturePacks.setColor( 'ui_prefab_editor_brush' )
        love.graphics.print( string.format( '%s (%s)', Translator.getText( self.tool:getID() ), type ), tw, (sh-2) * th )
        love.graphics.print( Translator.getText( template.id ), tw, (sh-1) * th )
        TexturePacks.resetColor()
    end
end

function PrefabEditor:update( dt )
    if not self:isActive() then
        return
    end

    self.camera:update( dt )

    self.uiContainer:update()

    self.canvas:update()

    self.tool:setTemplate( self.brush:getTemplate() )
    self.tool:setLayer( self.brush:getLayer() )
    self.tool:setIcon( self.brush:getIcon() )
    self.tool:setIconColorID( self.brush:getIconColorID() )

    self.tool:setPosition( self.camera:getMouseWorldGridPosition() )
    self.tool:use( self.canvas )
end

function PrefabEditor:keypressed( _, scancode )
    if scancode == 'escape' then
        ScreenManager.push( 'prefabeditormenu', self.canvas )
        return
    end

    local action = Settings.mapInput( Settings.INPUTLAYOUTS.PREFAB_EDITOR, scancode )

    if action == 'increase_tool_size' then
        self.tool:increaseSize()
    elseif action == 'decrease_tool_size' then
        self.tool:decreaseSize()
    end

    if action == 'mode_draw' then
        self.tool = DrawingTool()
    elseif action == 'mode_erase' then
        self.tool = EraserTool()
    elseif action == 'mode_fill' then
        self.tool = FillingTool()
    end

    if action == 'hide_worldobjects' then
        self.canvas:toggleObjects()
    end

    if scancode == 'tab' then
        if love.keyboard.isScancodeDown( 'lshift' ) then
            self.uiContainer:prev()
        else
            self.uiContainer:next()
        end
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
