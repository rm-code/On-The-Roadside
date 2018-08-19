---
-- @module MapTest
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Screen = require( 'src.ui.screens.Screen' )
local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local MapPainter = require( 'src.ui.MapPainter' )
local Camera = require( 'src.ui.Camera' )
local PrefabLoader = require( 'src.map.procedural.PrefabLoader' )
local ProceduralMapGenerator = require( 'src.map.procedural.ProceduralMapGenerator' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local Settings = require( 'src.Settings' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MapTest = Screen:subclass( 'MapTest' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

local function createMap( layout )
    return ProceduralMapGenerator():createMap( layout )
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function MapTest:initialize( layout )
    ProceduralMapGenerator.load()
    PrefabLoader.load()

    self.map = createMap( layout )
    self.mw, self.mh = self.map:getDimensions()
    self.mapPainter = MapPainter( self.map )
    self.camera = Camera( self.mw, self.mh, TexturePacks.getTileDimensions() )
end

function MapTest:draw()
    TexturePacks.setColor( 'sys_background' )
    love.graphics.rectangle( 'fill', 0, 0, love.graphics.getDimensions() )
    TexturePacks.resetColor()

    self.camera:attach()
    self.mapPainter:draw()
    self.camera:detach()
end

function MapTest:update( dt )
    if self.mapPainter then
        self.mapPainter:update()
    end
    self.camera:update( dt )
end

function MapTest:keypressed( _, scancode )
    if scancode == 'escape' then
        ScreenManager.pop()
    end

    self.camera:input( Settings.mapInput( Settings.INPUTLAYOUTS.COMBAT, scancode ), true )
end

function MapTest:keyreleased( _, scancode )
    self.camera:input( Settings.mapInput( Settings.INPUTLAYOUTS.COMBAT, scancode ), false )
end

return MapTest
