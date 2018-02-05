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
local UIVerticalList = require( 'src.ui.elements.lists.UIVerticalList' )
local UIButton = require( 'src.ui.elements.UIButton' )
local Camera = require( 'src.ui.Camera' )
local Translator = require( 'src.util.Translator' )
local PrefabCanvas = require( 'src.ui.mapeditor.PrefabCanvas' )
local PrefabBrush = require( 'src.ui.mapeditor.PrefabBrush' )
local UIContainer = require( 'src.ui.elements.UIContainer' )
local GridHelper = require( 'src.util.GridHelper' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local PrefabEditor = Screen:subclass( 'PrefabEditor' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local SELECTOR_WIDTH  = 10
local SELECTOR_HEIGHT = 10

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

local function createTileSelector( tileTemplates, tool )
    local lx, ly = 1, 1
    local tileSelector = UIVerticalList( lx, ly, 0, 0, SELECTOR_WIDTH, SELECTOR_HEIGHT )

    local counter = 0
    for id, template in pairs( tileTemplates ) do
        local function callback()
            tool:setBrush( template, 'tile' )
        end

        local tmp = UIButton( lx, ly, 0, counter, SELECTOR_WIDTH, 1, callback, Translator.getText( id ), 'left' )
        tmp:setIcon( id )
        tileSelector:addChild( tmp )

        counter = counter + 1
    end

    return tileSelector
end

local function createWorldObjectSelector( objectTemplates, tool )
    local lx, ly = 1, SELECTOR_HEIGHT + 2
    local objectSelector = UIVerticalList( lx, ly, 0, 0, SELECTOR_WIDTH, SELECTOR_HEIGHT )

    local counter = 0
    for id, template in pairs( objectTemplates ) do
        local function callback()
            tool:setBrush( template, 'worldObject' )
        end

        local tmp = UIButton( lx, ly, 0, counter, SELECTOR_WIDTH, 1, callback, Translator.getText( id ), 'left' )
        if template.openable then
            tmp:setIcon( id, 'closed' )
        elseif template.connections then
            tmp:setIcon( id, 'default' )
        else
            tmp:setIcon( id )
        end
        objectSelector:addChild( tmp )

        counter = counter + 1
    end

    return objectSelector
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

    self.uiContainer = UIContainer()
    self.uiContainer:register( self.tileSelector )
    self.uiContainer:register( self.objectSelector )
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
    end

    if scancode == ']' then
        self.tool:increase()
    elseif scancode == '/' then
        self.tool:decrease()
    end

    if scancode == 'd' then
        self.tool:setMode( 'draw' )
    elseif scancode == 'e' then
        self.tool:setMode( 'erase' )
    elseif scancode == 'f' then
        self.tool:setMode( 'fill' )
    end

    if scancode == '1' then
        self.canvas:setSize( 'XS' )
        self.camera = Camera( self.canvas:getWidth(), self.canvas:getHeight(), TexturePacks.getTileDimensions() )
    elseif scancode == '2' then
        self.canvas:setSize( 'S'  )
        self.camera = Camera( self.canvas:getWidth(), self.canvas:getHeight(), TexturePacks.getTileDimensions() )
    elseif scancode == '3' then
        self.canvas:setSize( 'M'  )
        self.camera = Camera( self.canvas:getWidth(), self.canvas:getHeight(), TexturePacks.getTileDimensions() )
    elseif scancode == '4' then
        self.canvas:setSize( 'L'  )
        self.camera = Camera( self.canvas:getWidth(), self.canvas:getHeight(), TexturePacks.getTileDimensions() )
    elseif scancode == '5' then
        self.canvas:setSize( 'XL' )
        self.camera = Camera( self.canvas:getWidth(), self.canvas:getHeight(), TexturePacks.getTileDimensions() )
    end

    if scancode == 'h' then
        self.canvas:toggleObjects()
    end

    if scancode == 'tab' then
        self.uiContainer:next()
    end

    if scancode == 'return' then
        self.uiContainer:command( 'activate' )
    end
    self.uiContainer:command( scancode )
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
