---
-- @module ExecutionState
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local Log = require( 'src.util.Log' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ExecutionState = Class( 'ExecutionState' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local FACTIONS = require( 'src.constants.FACTIONS' )
local AI_DELAY     = 0
local PLAYER_DELAY = 0.15

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function ExecutionState:initialize( stateManager )
    self.stateManager = stateManager
    self.actionTimer = 0
end

function ExecutionState:enter( factions, character, projectileManager )
    self.factions = factions
    self.character = character
    self.projectileManager = projectileManager

    self.delay = character:getFaction():isAIControlled() and AI_DELAY or PLAYER_DELAY
end

function ExecutionState:update( dt )
    if not self.projectileManager:isDone() then
        self.projectileManager:update( dt )
        return
    end

    if self.character:isDead() then
        Log.debug( string.format( 'Character (%s) is dead. Stopping execution', tostring( self.character )), 'ExecutionState' )
        self.stateManager:pop()
        return
    end

    if self.actionTimer > self.delay then
        if self.character:hasEnqueuedAction() then
            self.character:performAction()

            if self.character:getTile():isSeenBy( FACTIONS.ALLIED ) then
                self.delay = PLAYER_DELAY
            else
                self.delay = AI_DELAY
            end

            self.actionTimer = 0
        else
            self.stateManager:pop()
        end
    end
    self.actionTimer = self.actionTimer + dt
end

function ExecutionState:blocksInput()
    return true
end

return ExecutionState
