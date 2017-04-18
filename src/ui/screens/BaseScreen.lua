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
local NextMissionSelector = require( 'src.ui.elements.NextMissionSelector' )
local HealAllSelector = require( 'src.ui.elements.HealAllSelector' )
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
    local nextMissionSelector
    local healAllSelector
    local playerFaction

    function self:init( nplayerFaction, savegame )
        playerFaction = nplayerFaction

        baseState = BaseState.new()
        baseState:init( playerFaction, savegame )

        characterSelector = CharacterSelector.new()
        characterSelector:init( nplayerFaction )
        characterSelector:observe( self )

        nextMissionSelector = NextMissionSelector.new()
        nextMissionSelector:init()
        nextMissionSelector:observe( self )

        healAllSelector = HealAllSelector.new()
        healAllSelector:init()
        healAllSelector:observe( self )

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
        nextMissionSelector:draw()
        healAllSelector:draw()
    end

    function self:update( dt )
        if not self:isActive() then
            return
        end

        camera:update( dt )
        baseState:update()
        mapPainter:update()
        characterSelector:update()
        nextMissionSelector:update()
        healAllSelector:update()
        MousePointer.update()
    end

    function self:keypressed( _, scancode )
        if not self:isActive() then
            return
        end

        if scancode == 'i' and currentCharacter then
            ScreenManager.push( 'inventory', currentCharacter, baseState:getBaseInventory() )
        end
        if scancode == 'escape' then
            -- TODO save game is currently broken
            ScreenManager.push( 'basemenu', baseState )
        end
        characterSelector:keypressed( _, scancode )
    end

    function self:mousereleased()
        characterSelector:mousereleased()
        nextMissionSelector:mousereleased()
        healAllSelector:mousereleased()
    end

    function self:mousemoved()
        characterSelector:mousemoved()
        nextMissionSelector:mousemoved()
        healAllSelector:mousemoved()
    end

    function self:receive( event, ... )
        if event == 'HEAL_CHARACTERS' then
            -- TODO Replace with proper healing system.
            playerFaction:iterate( function( character )
                character:getBody():heal()
            end)
        elseif event == 'LOAD_COMBAT_MISSION' then
            ScreenManager.pop()
            ScreenManager.push( 'combat', playerFaction )
        elseif event == 'CHANGED_CHARACTER' then
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
