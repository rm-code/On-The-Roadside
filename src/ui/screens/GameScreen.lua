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
local Inventory = require( 'src.inventory.Inventory' )

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

local function loadGame( savegame )
    DataHandler.copyPlayerFaction( savegame.factions[FACTIONS.ALLIED] )
    DataHandler.copyBaseInventory( savegame.baseInventory )
    ScreenManager.switch( savegame.type, savegame )
end

local function newGame()
    local playerFaction = Faction( FACTIONS.ALLIED, false )
    playerFaction:addCharacters( 10 )

    local baseInventory = Inventory()

    DataHandler.copyPlayerFaction( playerFaction:serialize() )
    DataHandler.copyBaseInventory( baseInventory:serialize() )
    ScreenManager.switch( 'base' )
end

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function GameScreen:initialize( savegame )

    if savegame then
        loadGame( savegame )
    else
        newGame()
    end
end

return GameScreen
