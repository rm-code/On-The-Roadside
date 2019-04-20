---
-- @module MapEditor
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Screen = require( 'src.ui.screens.Screen' )
local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local UIVerticalList = require( 'src.ui.elements.lists.UIVerticalList' )
local UIButton = require( 'src.ui.elements.UIButton' )
local Camera = require( 'src.ui.Camera' )
local LayoutCanvas = require( 'src.map.editor.LayoutCanvas' )
local LayoutBrush = require( 'src.map.editor.LayoutBrush' )
local UIContainer = require( 'src.ui.elements.UIContainer' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MapEditor = Screen:subclass( 'MapEditor' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local MAP_LAYOUT_DIRECTORY = 'mods/maps/layouts'
local SELECTOR_WIDTH  = 10
local SELECTOR_HEIGHT = 10

local PREFAB_SIZES = {
    { TYPE = 'SPAWNS_FRIENDLY', WIDTH = 8, HEIGHT = 8, PARCEL_WIDTH = 1, PARCEL_HEIGHT = 1 },
    { TYPE = 'SPAWNS_NEUTRAL', WIDTH = 8, HEIGHT = 8, PARCEL_WIDTH = 1, PARCEL_HEIGHT = 1 },
    { TYPE = 'SPAWNS_ENEMY', WIDTH = 8, HEIGHT = 8, PARCEL_WIDTH = 1, PARCEL_HEIGHT = 1 },
    { TYPE = 'FOLIAGE', WIDTH =  8, HEIGHT =  8, PARCEL_WIDTH = 1, PARCEL_HEIGHT = 1 },
    { TYPE = 'ROAD', WIDTH =  8, HEIGHT =  8, PARCEL_WIDTH = 1, PARCEL_HEIGHT = 1 },
    { TYPE = 'XS', WIDTH =  8, HEIGHT =  8, PARCEL_WIDTH = 1, PARCEL_HEIGHT = 1 },
    { TYPE = 'S',  WIDTH = 16, HEIGHT = 16, PARCEL_WIDTH = 2, PARCEL_HEIGHT = 2 },
    { TYPE = 'M',  WIDTH = 32, HEIGHT = 32, PARCEL_WIDTH = 4, PARCEL_HEIGHT = 4 },
    { TYPE = 'L',  WIDTH = 48, HEIGHT = 48, PARCEL_WIDTH = 6, PARCEL_HEIGHT = 6 },
    { TYPE = 'XL', WIDTH = 56, HEIGHT = 56, PARCEL_WIDTH = 7, PARCEL_HEIGHT = 7 }
}

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

local function createPrefabSelector( brush )
    local lx, ly = 1, 1

    local prefabSelector = UIVerticalList( lx, ly, 0, 0, SELECTOR_WIDTH, SELECTOR_HEIGHT )

    local counter = 0
    for _, template in pairs( PREFAB_SIZES ) do
        local function callback()
            brush:setTemplate( template )
        end

        local str = string.format( '%2s (%sx%s)', template.TYPE, template.PARCEL_WIDTH, template.PARCEL_HEIGHT )
        local tmp = UIButton( lx, ly, 0, counter, SELECTOR_WIDTH, 1, callback, str, 'left' )
        prefabSelector:addChild( tmp )

        counter = counter + 1
    end

    return prefabSelector
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function MapEditor:initialize()
    love.filesystem.createDirectory( MAP_LAYOUT_DIRECTORY )
    love.mouse.setVisible( true )

    self.canvas = LayoutCanvas()
    self.brush = LayoutBrush( PREFAB_SIZES[1] )

    self.prefabSelector = createPrefabSelector( self.brush )

    self.camera = Camera( self.canvas:getWidth(), self.canvas:getHeight(), 16, 16 )

    self.uiContainer = UIContainer()
    self.uiContainer:register( self.prefabSelector )
end

function MapEditor:receive( event, ... )
    if event == 'LOAD_LAYOUT' then
        local newLayout = ...
        self.canvas:setGrid( newLayout )
    end
end

function MapEditor:draw()
    if not self:isActive() then
        return
    end

    self.uiContainer:draw()

    self.camera:attach()
    self.canvas:draw()
    self.brush:draw()
    self.camera:detach()
end

function MapEditor:update( dt )
    if not self:isActive() then
        return
    end

    self.camera:update( dt )
    self.brush:setPosition( self.camera:getMouseWorldGridPosition() )
    self.uiContainer:update()
end

function MapEditor:mousemoved()
    love.mouse.setVisible( true )
end

function MapEditor:mousepressed()
    self.brush:use( self.canvas )
    self.uiContainer:command( 'activate' )
end

function MapEditor:keypressed( _, scancode )
    if scancode == 'escape' then
        ScreenManager.push( 'mapeditormenu', self.canvas )
    end

    if scancode == 'tab' then
        self.uiContainer:next()
    end

    if scancode == 'd' then
        self.brush:setMode( 'draw' )
    elseif scancode == 'e' then
        self.brush:setMode( 'erase' )
    end

    if scancode == 'up' then
        self.uiContainer:command( 'up' )
    elseif scancode == 'down' then
        self.uiContainer:command( 'down' )
    elseif scancode == 'return' then
        self.uiContainer:command( 'activate' )
    end

    if scancode == 'w' then
        self.canvas:resize( 0, -1 )
    elseif scancode == 's' then
        self.canvas:resize( 0, 1 )
    end
    if scancode == 'a' then
        self.canvas:resize( -1, 0 )
    elseif scancode == 'd' then
        self.canvas:resize( 1, 0 )
    end
end

return MapEditor
