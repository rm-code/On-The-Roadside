---
-- @module MapEditor
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Screen = require( 'lib.screenmanager.Screen' )
local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local UIVerticalList = require( 'src.ui.elements.lists.UIVerticalList' )
local UIButton = require( 'src.ui.elements.UIButton' )
local CameraHandler = require('src.ui.CameraHandler')
local LayoutCanvas = require( 'src.ui.mapeditor.LayoutCanvas' )
local LayoutBrush = require( 'src.ui.mapeditor.LayoutBrush' )
local UIContainer = require( 'src.ui.elements.UIContainer' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MapEditor = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local MAP_LAYOUT_DIRECTORY = 'mods/maps/layouts'
local SELECTOR_WIDTH  = 10
local SELECTOR_HEIGHT = 10

local PREFAB_SIZES = {
    { TYPE = 'FOLIAGE', WIDTH =  8, HEIGHT =  8, PARCEL_WIDTH = 1, PARCEL_HEIGHT = 1 },
    { TYPE = 'ROAD', WIDTH =  8, HEIGHT =  8, PARCEL_WIDTH = 1, PARCEL_HEIGHT = 1 },
    { TYPE = 'XS', WIDTH =  8, HEIGHT =  8, PARCEL_WIDTH = 1, PARCEL_HEIGHT = 1 },
    { TYPE = 'S',  WIDTH = 16, HEIGHT = 16, PARCEL_WIDTH = 2, PARCEL_HEIGHT = 2 },
    { TYPE = 'M',  WIDTH = 32, HEIGHT = 32, PARCEL_WIDTH = 4, PARCEL_HEIGHT = 4 },
    { TYPE = 'L',  WIDTH = 48, HEIGHT = 48, PARCEL_WIDTH = 6, PARCEL_HEIGHT = 6 },
    { TYPE = 'XL', WIDTH = 56, HEIGHT = 56, PARCEL_WIDTH = 7, PARCEL_HEIGHT = 7 }
}

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function MapEditor.new()
    local self = Screen.new()

    -- ------------------------------------------------
    -- Private Variables
    -- ------------------------------------------------

    local camera

    local prefabSelector

    local canvas
    local brush

    local uiContainer

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    local function createPrefabSelector()
        local lx, ly = 1, 1

        prefabSelector = UIVerticalList( lx, ly, 0, 0, SELECTOR_WIDTH, SELECTOR_HEIGHT )

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
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init()
        love.filesystem.createDirectory( MAP_LAYOUT_DIRECTORY )
        love.mouse.setVisible( true )

        canvas = LayoutCanvas()
        brush = LayoutBrush( PREFAB_SIZES[1] )

        createPrefabSelector()

        camera = CameraHandler.new( canvas:getWidth(), canvas:getHeight(), 16, 16 )

        uiContainer = UIContainer()
        uiContainer:register( prefabSelector )
    end

    function self:receive( event, ... )
        if event == 'LOAD_LAYOUT' then
            local newLayout = ...
            canvas:setGrid( newLayout )
        end
    end

    function self:draw()
        if not self:isActive() then
            return
        end

        uiContainer:draw()

        camera:attach()
        canvas:draw()
        brush:draw()
        camera:detach()
    end

    function self:update( dt )
        if not self:isActive() then
            return
        end

        camera:update( dt )
        brush:setPosition( camera:getMouseWorldGridPosition() )
        uiContainer:update()
    end

    function self:mousemoved()
        love.mouse.setVisible( true )
    end

    function self:mousepressed()
        brush:use( canvas )
        uiContainer:command( 'activate' )
    end

    function self:keypressed( _, scancode )
        if scancode == 'escape' then
            ScreenManager.push( 'mapeditormenu', canvas )
        end

        if scancode == 'tab' then
            uiContainer:next()
        end

        if scancode == 'd' then
            brush:setMode( 'draw' )
        elseif scancode == 'e' then
            brush:setMode( 'erase' )
        end

        if scancode == 'up' then
            uiContainer:command( 'up' )
        elseif scancode == 'down' then
            uiContainer:command( 'down' )
        elseif scancode == 'return' then
            uiContainer:command( 'activate' )
        end

        if scancode == 'w' then
            canvas:resize( 0, -1 )
        elseif scancode == 's' then
            canvas:resize( 0, 1 )
        end
        if scancode == 'a' then
            canvas:resize( -1, 0 )
        elseif scancode == 'd' then
            canvas:resize( 1, 0 )
        end
    end

    return self
end

return MapEditor
