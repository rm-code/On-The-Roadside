local StateManager = require( 'src.turnbased.states.StateManager' );
local ScreenManager = require( 'lib.screenmanager.ScreenManager' );
local State = require( 'src.turnbased.states.State' );
local Reload = require( 'src.characters.actions.Reload' );
local StandUp = require( 'src.characters.actions.StandUp' );
local Crouch = require( 'src.characters.actions.Crouch' );
local LieDown = require( 'src.characters.actions.LieDown' );
local OpenInventory = require( 'src.characters.actions.OpenInventory' );

local PlanningState = {};

function PlanningState.new( stateManager )
    local self = State.new():addInstance( 'PlanningState' );

    local factions;
    local inputStates = {
        attack = require( 'src.turnbased.helpers.AttackInput' ),
        movement = require( 'src.turnbased.helpers.MovementInput' ),
        interaction = require( 'src.turnbased.helpers.InteractionInput' )
    }
    local inputStateHandler = StateManager.new( inputStates );
    inputStateHandler:switch( 'movement' );

    function self:enter( nfactions )
        factions = nfactions;
    end

    function self:update()
        if factions:getFaction():getCurrentCharacter():isDead() then
            if factions:getFaction():hasLivingCharacters() then
                factions:getFaction():nextCharacter();
            else
                factions:nextFaction();
            end
        end
    end

    -- TODO Refactor input handling.
    function self:keypressed( _, scancode, _ )
        local character = factions:getFaction():getCurrentCharacter();
        if character:isDead() then
            return;
        end

        if scancode == 'right' then
            if not character:getWeapon() then
                return;
            end
            character:getWeapon():selectNextFiringMode();
        elseif scancode == 'left' then
            if not character:getWeapon() then
                return;
            end
            character:getWeapon():selectPrevFiringMode();
        elseif scancode == 'c' then
            character:clearActions();
            character:enqueueAction( Crouch( character ))
            stateManager:push( 'execution', factions, character );
        elseif scancode == 's' then
            character:clearActions();
            character:enqueueAction( StandUp( character ))
            stateManager:push( 'execution', factions, character );
        elseif scancode == 'p' then
            character:clearActions();
            character:enqueueAction( LieDown( character ))
            stateManager:push( 'execution', factions, character );
        elseif scancode == 'r' then
            character:clearActions();
            character:enqueueAction( Reload.new( character ));
            stateManager:push( 'execution', factions, character );
        elseif scancode == 'a' then
            -- Make attack mode toggleable.
            character:clearActions();
            if inputStateHandler:getState():instanceOf( 'AttackInput' ) then
                inputStateHandler:switch( 'movement' );
            else
                inputStateHandler:switch( 'attack' );
            end
        elseif scancode == 'e' then
            character:clearActions();
            if inputStateHandler:getState():instanceOf( 'InteractionInput' ) then
                inputStateHandler:switch( 'movement' );
            else
                inputStateHandler:switch( 'interaction' );
            end
        elseif scancode == 'm' then
            character:clearActions();
            inputStateHandler:switch( 'movement' );
        elseif scancode == 'space' then
            inputStateHandler:switch( 'movement' );
            factions:getFaction():nextCharacter();
        elseif scancode == 'backspace' then
            inputStateHandler:switch( 'movement' );
            factions:getFaction():prevCharacter();
        elseif scancode == 'return' then
            inputStateHandler:switch( 'movement' );
            factions:nextFaction();
        elseif scancode == 'i' then
            character:enqueueAction( OpenInventory( character, character:getTile() ))
            stateManager:push( 'execution', factions, character );
        elseif scancode == 'h' then
            ScreenManager.push( 'health', character );
        end
    end

    function self:selectTile( tile, button )
        local character = factions:getFaction():getCurrentCharacter();
        if not tile or character:isDead() then
            return;
        end

        if button == 2 and tile:isOccupied() then
            inputStateHandler:switch( 'movement' );
            factions:getFaction():selectCharacter( tile:getCharacter() );
            return;
        end

        -- Request actions to execute.
        local execute = inputStateHandler:getState():request( tile, character );
        if execute then
            stateManager:push( 'execution', factions, character );
        end
    end

    function self:getInputMode()
        return inputStateHandler:getState();
    end

    function self:blocksInput()
        return false;
    end

    return self;
end

return PlanningState;
