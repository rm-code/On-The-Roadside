---
-- @module PlanningState
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local StateManager = require( 'src.turnbased.StateManager' )
local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local Reload = require( 'src.characters.actions.Reload' )
local StandUp = require( 'src.characters.actions.StandUp' )
local Crouch = require( 'src.characters.actions.Crouch' )
local LieDown = require( 'src.characters.actions.LieDown' )
local OpenInventory = require( 'src.characters.actions.OpenInventory' )
local AttackInput = require( 'src.turnbased.helpers.AttackInput' )
local InteractionInput = require( 'src.turnbased.helpers.InteractionInput' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local PlanningState = Class( 'PlanningState' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function PlanningState:initialize( stateManager )
    self.stateManager = stateManager

    local inputStates = {
        attack = require( 'src.turnbased.helpers.AttackInput' ),
        movement = require( 'src.turnbased.helpers.MovementInput' ),
        interaction = require( 'src.turnbased.helpers.InteractionInput' )
    }

    self.inputStateHandler = StateManager( inputStates )
    self.inputStateHandler:switch( 'movement' )
end

function PlanningState:enter( factions )
    self.factions = factions
end

function PlanningState:update()
    if self.factions:getFaction():getCurrentCharacter():isDead() then
        if self.factions:getFaction():hasLivingCharacters() then
            self.factions:getFaction():nextCharacter()
        else
            self.factions:nextFaction()
        end
    end
end

-- TODO Refactor input handling.
function PlanningState:keypressed( _, scancode, _ )
    local character = self.factions:getFaction():getCurrentCharacter()
    if character:isDead() then
        return
    end

    if scancode == 'right' then
        if not character:getWeapon() then
            return
        end
        character:getWeapon():selectNextFiringMode()
    elseif scancode == 'left' then
        if not character:getWeapon() then
            return
        end
        character:getWeapon():selectPrevFiringMode()
    elseif scancode == 'c' then
        character:clearActions()
        character:enqueueAction( Crouch( character ))
        self.stateManager:push( 'execution', self.factions, character )
    elseif scancode == 's' then
        character:clearActions()
        character:enqueueAction( StandUp( character ))
        self.stateManager:push( 'execution', self.factions, character )
    elseif scancode == 'p' then
        character:clearActions()
        character:enqueueAction( LieDown( character ))
        self.stateManager:push( 'execution', self.factions, character )
    elseif scancode == 'r' then
        character:clearActions()
        character:enqueueAction( Reload( character ))
        self.stateManager:push( 'execution', self.factions, character )
    elseif scancode == 'a' then
        -- Make attack mode toggleable.
        character:clearActions()
        if self.inputStateHandler:getState():isInstanceOf( AttackInput ) then
            self.inputStateHandler:switch( 'movement' )
        else
            self.inputStateHandler:switch( 'attack' )
        end
    elseif scancode == 'e' then
        character:clearActions()
        if self.inputStateHandler:getState():isInstanceOf( InteractionInput ) then
            self.inputStateHandler:switch( 'movement' )
        else
            self.inputStateHandler:switch( 'interaction' )
        end
    elseif scancode == 'm' then
        character:clearActions()
        self.inputStateHandler:switch( 'movement' )
    elseif scancode == 'space' then
        self.inputStateHandler:switch( 'movement' )
        self.factions:getFaction():nextCharacter()
    elseif scancode == 'backspace' then
        self.inputStateHandler:switch( 'movement' )
        self.factions:getFaction():prevCharacter()
    elseif scancode == 'return' then
        self.inputStateHandler:switch( 'movement' )
        self.factions:nextFaction()
    elseif scancode == 'i' then
        character:enqueueAction( OpenInventory( character, character:getTile() ))
        self.stateManager:push( 'execution', self.factions, character )
    elseif scancode == 'h' then
        ScreenManager.push( 'health', character )
    end
end

function PlanningState:selectTile( tile, button )
    local character = self.factions:getFaction():getCurrentCharacter()
    if not tile or character:isDead() then
        return
    end

    if button == 2 and tile:isOccupied() then
        self.inputStateHandler:switch( 'movement' )
        self.factions:getFaction():selectCharacter( tile:getCharacter() )
        return
    end

    -- Request actions to execute.
    local execute = self.inputStateHandler:getState():request( tile, character )
    if execute then
        self.stateManager:push( 'execution', self.factions, character )
    end
end

function PlanningState:getInputMode()
    return self.inputStateHandler:getState()
end

function PlanningState:blocksInput()
    return false
end

return PlanningState
