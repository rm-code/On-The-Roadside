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
local MovementInput = require( 'src.turnbased.helpers.MovementInput' )
local InteractionInput = require( 'src.turnbased.helpers.InteractionInput' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local PlanningState = Class( 'PlanningState' )

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

local function handleCharacterActions( input, character )
    local action
    if input == 'action_crouch' then
        action = Crouch( character )
    elseif input == 'action_stand' then
        action = StandUp( character )
    elseif input == 'action_prone' then
        action = LieDown( character )
    elseif input == 'action_reload_weapon' then
        action = Reload( character )
    else
        return false
    end

    character:clearActions()
    character:enqueueAction( action )
    return true
end

local function handleInputSelectionActions( input, inputStateHandler, character )
    if input == 'attack_mode' then
        if inputStateHandler:getState():isInstanceOf( AttackInput ) then
            inputStateHandler:switch( 'movement' )
        else
            inputStateHandler:switch( 'attack' )
        end
    elseif input == 'interaction_mode' then
        if inputStateHandler:getState():isInstanceOf( InteractionInput ) then
            inputStateHandler:switch( 'movement' )
        else
            inputStateHandler:switch( 'interaction' )
        end
    elseif input == 'movement_mode' then
        inputStateHandler:switch( 'movement' )
    else
        return false
    end

    character:clearActions()
    return true
end

local function handleOtherActions( input, stateManager, inputStateHandler, factions, character, projectileManager )
    if input == 'next_character' then
        inputStateHandler:switch( 'movement' )
        factions:getFaction():nextCharacter()
        return true
    elseif input == 'prev_character' then
        inputStateHandler:switch( 'movement' )
        factions:getFaction():prevCharacter()
        return true
    end

    if input == 'end_turn' then
        inputStateHandler:switch( 'movement' )
        factions:nextFaction()
        return true
    end

    if input == 'open_inventory_screen' then
        character:enqueueAction( OpenInventory( character, character:getTile() ))
        stateManager:push( 'execution', factions, character, projectileManager )
        return true
    elseif input == 'open_health_screen' then
        ScreenManager.push( 'playerInfo', character )
        return true
    end

    if not character:getWeapon() then
        return false
    end

    if input == 'next_weapon_mode' then
        character:getWeapon():selectNextFiringMode()
    elseif input == 'prev_weapon_mode' then
        character:getWeapon():selectPrevFiringMode()
    end

    return true
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function PlanningState:initialize( stateManager )
    self.stateManager = stateManager

    local inputStates = {
        attack = AttackInput,
        movement = MovementInput,
        interaction = InteractionInput
    }

    self.inputStateHandler = StateManager( inputStates )
    self.inputStateHandler:switch( 'movement' )
end

function PlanningState:enter( factions, projectileManager )
    self.factions = factions
    self.projectileManager = projectileManager
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

function PlanningState:input( input )
    local character = self.factions:getFaction():getCurrentCharacter()
    if character:isDead() then
        return
    end

    if handleCharacterActions( input, character ) then
        self.stateManager:push( 'execution', self.factions, character, self.projectileManager )
        return
    end

    if handleInputSelectionActions( input, self.inputStateHandler, character ) then
        return
    end

    if handleOtherActions( input, self.stateManager, self.inputStateHandler, self.factions, character, self.projectileManager ) then
        return
    end
end

function PlanningState:selectTile( tile, button )
    local character = self.factions:getFaction():getCurrentCharacter()
    if not tile or character:isDead() then
        return
    end

    if button == 2 and tile:hasCharacter() then
        self.inputStateHandler:switch( 'movement' )
        self.factions:getFaction():selectCharacter( tile:getCharacter() )
        return
    end

    -- Request actions to execute.
    local execute = self.inputStateHandler:getState():request( tile, character, self.projectileManager )
    if execute then
        self.stateManager:push( 'execution', self.factions, character, self.projectileManager )
    end
end

function PlanningState:getInputMode()
    return self.inputStateHandler:getState()
end

function PlanningState:blocksInput()
    return false
end

return PlanningState
