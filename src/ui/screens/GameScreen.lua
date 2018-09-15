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
local DataHandler = require( 'src.DataHandler' )

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

local function loadGame( savegame, playerFaction )
    playerFaction:loadCharacters( savegame.factions[FACTIONS.ALLIED] )
    DataHandler.copyPlayerFaction( playerFaction:serialize() )
    ScreenManager.switch( savegame.type, savegame )
end

local function newGame( playerFaction )
    playerFaction:addCharacters( 10 )
    DataHandler.copyPlayerFaction( playerFaction:serialize() )
    ScreenManager.switch( 'base' )
end

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function GameScreen:initialize( savegame )
    local playerFaction = Faction( FACTIONS.ALLIED, false )

    if savegame then
        loadGame( savegame, playerFaction )
    else
        newGame( playerFaction )
    end
end

return GameScreen
