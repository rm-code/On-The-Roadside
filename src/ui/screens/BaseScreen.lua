---
-- The game screen is the topmost game screen / state and acts as a parent for
-- all the other parts of the game (such as combat and base views).
--
-- @module BaseScreen
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Screen = require( 'lib.screenmanager.Screen' )
local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local BaseState = require( 'src.BaseState' )
local MapPainter = require( 'src.ui.MapPainter' )
local CameraHandler = require( 'src.ui.CameraHandler' )
local MousePointer = require( 'src.ui.MousePointer' )
local CharacterSelector = require( 'src.ui.elements.CharacterSelector' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local BaseScreen = {}

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function BaseScreen.new()
    local self = Screen.new()

    local baseState
    local mapPainter
    local camera
    local currentCharacter
    local characterSelector

    function self:init()
        baseState = BaseState.new()
        baseState:init()

        characterSelector = CharacterSelector.new()
        characterSelector:init( baseState:getFactions() )
        characterSelector:observe( self )

        mapPainter = MapPainter.new()
        mapPainter:init( baseState:getMap(), baseState:getFactions() )

        camera = CameraHandler.new( baseState:getMap() )

        MousePointer.init( camera )
    end

    function self:draw()
        camera:attach()
        mapPainter:draw()
        camera:detach()

        characterSelector:draw()
    end

    function self:update( dt )
        camera:update( dt )
        baseState:update()
        mapPainter:update()
        characterSelector:update()
        MousePointer.update()
    end

    function self:keypressed( _, scancode )
        if scancode == 'i' and currentCharacter then
            ScreenManager.push( 'inventory', currentCharacter, baseState:getBaseInventory() )
        end
        characterSelector:keypressed( _, scancode )
    end

    function self:receive( event, ... )
        if event == 'CHANGED_CHARACTER' then
            currentCharacter = ...
            local tx, ty = currentCharacter:getTile():getPosition()
            local tw, th = TexturePacks.getTileDimensions()
            camera:setTargetPosition( tx * tw, ty * th )
            baseState:getFactions():getFaction():selectCharacter( currentCharacter )
        end
    end

    return self
end

return BaseScreen
