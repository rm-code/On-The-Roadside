local Screen = require( 'lib.screenmanager.Screen' )
local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local MapPainter = require( 'src.ui.MapPainter' )
local CameraHandler = require('src.ui.CameraHandler')
local PrefabLoader = require( 'src.map.procedural.PrefabLoader' )
local ProceduralMapGenerator = require( 'src.map.procedural.ProceduralMapGenerator' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local Map = require( 'src.map.Map' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local MapTest = {}

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function MapTest.new()
    local self = Screen.new()

    local layout
    local map, mw, mh
    local mapPainter
    local camera

    local function createMap()
        local generator = ProceduralMapGenerator( layout )

        local tiles = generator:getTiles()
        mw, mh = generator:getTileGridDimensions()

        map = Map.new()
        map:init( tiles, mw, mh )
        map:setSpawnpoints( generator:getSpawnpoints() )
    end

    function self:init( nlayout )
        layout = nlayout

        ProceduralMapGenerator.load()
        PrefabLoader.load()

        createMap()

        mapPainter = MapPainter( map )

        camera = CameraHandler.new( mw, mh, TexturePacks.getTileDimensions() )
    end

    function self:draw()
        TexturePacks.setColor( 'sys_background' )
        love.graphics.rectangle( 'fill', 0, 0, love.graphics.getDimensions() )
        TexturePacks.resetColor()

        camera:attach()
        mapPainter:draw()
        camera:detach()
    end

    function self:update( dt )
        if mapPainter then
            mapPainter:update()
        end
        camera:update( dt )
    end

    function self:keypressed( _, scancode )
        if scancode == 'escape' then
            ScreenManager.pop()
        end
    end

    return self
end

return MapTest
