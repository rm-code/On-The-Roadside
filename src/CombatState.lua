---
-- @module CombatState
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local ProceduralMapGenerator = require( 'src.map.procedural.ProceduralMapGenerator' )
local MapLoader = require( 'src.map.MapLoader' )
local Factions = require( 'src.characters.Factions' )
local ProjectileManager = require( 'src.items.weapons.ProjectileManager' )
local ExplosionManager = require( 'src.items.weapons.ExplosionManager' )
local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local StateManager = require( 'src.turnbased.StateManager' )
local SadisticAIDirector = require( 'src.characters.ai.SadisticAIDirector' )
local Faction = require( 'src.characters.Faction' )
local Settings = require( 'src.Settings' )
local MessageQueue = require( 'src.util.MessageQueue' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local CombatState = Class( 'CombatState' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FACTIONS = require( 'src.constants.FACTIONS' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

local function loadMap( savedMap )
    return MapLoader():recreateMap( savedMap )
end

local function createMap()
    return ProceduralMapGenerator():createMap()
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function CombatState:initialize( playerFaction, savegame )
    self.states = {
        execution = require( 'src.turnbased.states.ExecutionState' ),
        planning  = require( 'src.turnbased.states.PlanningState' )
    }

    if savegame then
        self.map = loadMap( savegame.map )
    else
        self.map = createMap()
    end

    self.factions = Factions()
    self.factions:addFaction( Faction( FACTIONS.ENEMY,   true ))
    self.factions:addFaction( Faction( FACTIONS.NEUTRAL, true ))
    self.factions:addFaction( playerFaction )

    if savegame then
        self.factions:findFaction( FACTIONS.ENEMY   ):loadCharacters( savegame.factions[FACTIONS.ENEMY]   )
        self.factions:findFaction( FACTIONS.NEUTRAL ):loadCharacters( savegame.factions[FACTIONS.NEUTRAL] )
    else
        self.factions:findFaction( FACTIONS.ENEMY   ):addCharacters( 10 )
        self.factions:findFaction( FACTIONS.NEUTRAL ):addCharacters(  5 )
    end

    self.factions:findFaction( FACTIONS.ENEMY   ):spawnCharacters( self.map )
    self.factions:findFaction( FACTIONS.NEUTRAL ):spawnCharacters( self.map )
    playerFaction:spawnCharacters( self.map )

    -- Generate initial FOV for all factions.
    self.factions:iterate( function( faction )
        faction:iterate( function( character )
            character:generateFOV()
        end)
    end)

    self.stateManager = StateManager( self.states )
    self.stateManager:push( 'planning', self.factions )

    self.sadisticAIDirector = SadisticAIDirector( self.factions, self.stateManager )

    ProjectileManager.init( self.map )
    ExplosionManager.init( self.map )

    -- Register observations.
    self.map:observe( self )
    self.map:observe( self.factions )

    -- Clear the message queue.
    MessageQueue.clear()

    -- Free memory if possible.
    collectgarbage( 'collect' )
end

function CombatState:update( dt )
    -- Update AI if current faction is AI controlled.
    if self.factions:getFaction():isAIControlled() and not self.stateManager:blocksInput() then
        self.sadisticAIDirector:update( dt )
    end
    self.stateManager:update( dt )

    if not self.factions:getPlayerFaction():hasLivingCharacters() then
        ScreenManager.pop()
        ScreenManager.push( 'gameover', self.factions:getPlayerFaction(), false )
    end
    if not self.factions:findFaction( FACTIONS.ENEMY ):hasLivingCharacters() then
        ScreenManager.pop()
        ScreenManager.push( 'gameover', self.factions:getPlayerFaction(), true )
    end
end

function CombatState:receive( event, ... )
    if event == 'MESSAGE_LOG_EVENT' then
        local origin, msg, type = ...
        if origin:isSeenBy( FACTIONS.ALLIED ) then
            MessageQueue.enqueue( msg, type )
        end
    end
end

function CombatState:serialize()
    local t = {
        ['type'] = 'combat',
        ['map'] = self.map:serialize(),
        ['factions'] = self.factions:serialize()
    }
    return t
end

function CombatState:close()
    ProjectileManager.clear()
    ExplosionManager.clear()
end

function CombatState:keypressed( _, scancode, _ )
    if self.factions:getFaction():isAIControlled() or self.stateManager:blocksInput() then
        return
    end
    self.stateManager:input( Settings.mapInput( Settings.INPUTLAYOUTS.COMBAT, scancode ))
end

function CombatState:mousepressed( mx, my, button )
    if self.factions:getFaction():isAIControlled() or self.stateManager:blocksInput() then
        return
    end
    self.stateManager:selectTile( self.map:getTileAt( mx, my ), button )
end

function CombatState:getMap()
    return self.map
end

function CombatState:getFactions()
    return self.factions
end

function CombatState:getState()
    return self.stateManager:getState()
end

function CombatState:getPlayerFaction()
    return self.factions:getPlayerFaction()
end

function CombatState:getCurrentCharacter()
    return self.factions:getFaction():getCurrentCharacter()
end

return CombatState
