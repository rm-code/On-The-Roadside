---
-- The game screen is the topmost game screen / state and acts as a parent for
-- all the other parts of the game (such as combat and base views).
--
-- @module GameScreen
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Screen = require( 'lib.screenmanager.Screen' )
local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local Faction = require( 'src.characters.Faction' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local GameScreen = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FACTIONS = require( 'src.constants.FACTIONS' )

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function GameScreen.new()
    local self = Screen.new()

    function self:init( savegame )
        local playerFaction = Faction.new( FACTIONS.ALLIED, false )

        if savegame then
            playerFaction:loadCharacters( savegame.factions[FACTIONS.ALLIED] )
        else
            playerFaction:addCharacters( 10, 'human' )
        end

        local state = savegame and savegame.type or 'base'
        ScreenManager.push( state, playerFaction, savegame )
    end

    function self:draw()
    end

    function self:update()
    end

    return self
end

return GameScreen
