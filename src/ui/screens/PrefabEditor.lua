---
-- @module PrefabEditor
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Screen = require( 'lib.screenmanager.Screen' )
local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local TileFactory = require( 'src.map.tiles.TileFactory' )
local WorldObjectFactory = require( 'src.map.worldobjects.WorldObjectFactory' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local UIVerticalList = require( 'src.ui.elements.lists.UIVerticalList' )
local UIButton = require( 'src.ui.elements.UIButton' )
local CameraHandler = require('src.ui.CameraHandler')
local Translator = require( 'src.util.Translator' )
local PrefabCanvas = require( 'src.ui.mapeditor.PrefabCanvas' )
local PrefabBrush = require( 'src.ui.mapeditor.PrefabBrush' )
local UIContainer = require( 'src.ui.elements.UIContainer' )
local GridHelper = require( 'src.util.GridHelper' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local PrefabEditor = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local SELECTOR_WIDTH  = 10
local SELECTOR_HEIGHT = 10

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function PrefabEditor.new()
    local self = Screen.new()

    -- ------------------------------------------------
    -- Private Variables
    -- ------------------------------------------------

    local camera

    local tileTemplates
    local objectTemplates

    local tileSelector
    local objectSelector

    local canvas
    local tool

    local uiContainer

    -- ------------------------------------------------
    -- Private Functions
    -- ------------------------------------------------

    local function createTileSelector()
        local lx, ly = 1, 1

        tileSelector = UIVerticalList( lx, ly, 0, 0, SELECTOR_WIDTH, SELECTOR_HEIGHT )

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
    end

    local function createWorldObjectSelector()
        local lx, ly = 1, SELECTOR_HEIGHT + 2

        objectSelector = UIVerticalList( lx, ly, 0, 0, SELECTOR_WIDTH, SELECTOR_HEIGHT )

        local counter = 0
        for id, template in pairs( objectTemplates ) do
            local function callback()
                tool:setBrush( template, 'worldObject' )
            end

            local tmp = UIButton( lx, ly, 0, counter, SELECTOR_WIDTH, 1, callback, Translator.getText( id ), 'left' )
            if template.openable then
                tmp:setIcon( id, 'closed' )
            else
                tmp:setIcon( id )
            end
            objectSelector:addChild( tmp )

            counter = counter + 1
        end
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init()
        love.filesystem.createDirectory( 'mods/maps/prefabs' )
        love.mouse.setVisible( true )

        canvas = PrefabCanvas( 'XS' )

        camera = CameraHandler.new( canvas:getWidth(), canvas:getHeight(), TexturePacks.getTileDimensions() )

        tileTemplates = TileFactory.getTemplates()
        createTileSelector( tileTemplates )

        objectTemplates = WorldObjectFactory.getTemplates()
        createWorldObjectSelector( objectTemplates )

        tool = PrefabBrush()

        uiContainer = UIContainer()
        uiContainer:register( tileSelector )
        uiContainer:register( objectSelector )
    end

    function self:receive( event, ... )
        if event == 'LOAD_LAYOUT' then
            local newLayout = ...
            canvas:load( newLayout )
        end
    end

    function self:draw()
        tileSelector:draw()
        objectSelector:draw()

        camera:attach()
        canvas:draw()
        tool:draw()
        camera:detach()

        local  _, sh = GridHelper.getScreenGridDimensions()
        local tw, th = TexturePacks.getTileDimensions()

        local template, type = tool:getBrush()
        if template then
            love.graphics.print( string.format( 'Selected brush: %s (%s)', Translator.getText( template.id ), type ), tw, (sh-1) * th )
        end
    end

    function self:update( dt )
        camera:update( dt )

        uiContainer:update()

        tool:setPosition( camera:getMouseWorldGridPosition() )
        tool:use( canvas, camera )
    end

    function self:keypressed( _, scancode )
        if scancode == 'escape' then
            ScreenManager.push( 'prefabeditormenu', canvas )
        end

        if scancode == ']' then
            tool:increase()
        elseif scancode == '/' then
            tool:decrease()
        end

        if scancode == 'd' then
            tool:setMode( 'draw' )
        elseif scancode == 'e' then
            tool:setMode( 'erase' )
        elseif scancode == 'f' then
            tool:setMode( 'fill' )
        end

        if scancode == '1' then
            canvas:setSize( 'XS' )
            camera = CameraHandler.new( canvas:getWidth(), canvas:getHeight(), TexturePacks.getTileDimensions() )
        elseif scancode == '2' then
            canvas:setSize( 'S'  )
            camera = CameraHandler.new( canvas:getWidth(), canvas:getHeight(), TexturePacks.getTileDimensions() )
        elseif scancode == '3' then
            canvas:setSize( 'M'  )
            camera = CameraHandler.new( canvas:getWidth(), canvas:getHeight(), TexturePacks.getTileDimensions() )
        elseif scancode == '4' then
            canvas:setSize( 'L'  )
            camera = CameraHandler.new( canvas:getWidth(), canvas:getHeight(), TexturePacks.getTileDimensions() )
        elseif scancode == '5' then
            canvas:setSize( 'XL' )
            camera = CameraHandler.new( canvas:getWidth(), canvas:getHeight(), TexturePacks.getTileDimensions() )
        end

        if scancode == 'h' then
            canvas:toggleObjects()
        end

        if scancode == 'tab' then
            uiContainer:next()
        end

        if scancode == 'return' then
            uiContainer:command( 'activate' )
        end
        uiContainer:command( scancode )
    end

    function self:mousemoved()
        love.mouse.setVisible( true )
    end

    function self:mousepressed()
        uiContainer:mousecommand( 'activate' )
        tool:setActive( true )
    end

    function self:mousereleased()
        tool:setActive( false )
    end

    return self
end

return PrefabEditor
