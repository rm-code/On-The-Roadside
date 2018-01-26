---
-- The game screen is the topmost game screen / state and acts as a parent for
-- all the other parts of the game (such as combat and base views).
--
-- @module GameScreen
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Screen = require( 'src.ui.screens.Screen' )
local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local Faction = require( 'src.characters.Faction' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local GameScreen = Screen:subclass( 'GameScreen' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FACTIONS = require( 'src.constants.FACTIONS' )

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function GameScreen:initialize( savegame )
    local playerFaction = Faction( FACTIONS.ALLIED, false )

    if savegame then
        playerFaction:loadCharacters( savegame.factions[FACTIONS.ALLIED] )
    else
        playerFaction:addCharacters( 10 )
    end

    local state = savegame and savegame.type or 'combat'
    ScreenManager.push( state, playerFaction, savegame )
end

return GameScreen
