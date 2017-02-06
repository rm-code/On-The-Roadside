local ScreenManager = require( 'lib.screenmanager.ScreenManager' );
local State = require( 'src.turnbased.states.State' );
local Reload = require( 'src.characters.actions.Reload' );
local StandUp = require( 'src.characters.actions.StandUp' );
local Crouch = require( 'src.characters.actions.Crouch' );
local LieDown = require( 'src.characters.actions.LieDown' );
local OpenInventory = require( 'src.characters.actions.OpenInventory' );
local AttackInput = require( 'src.turnbased.helpers.AttackInput' );
local MovementInput = require( 'src.turnbased.helpers.MovementInput' );
local InteractionInput = require( 'src.turnbased.helpers.InteractionInput' );

local PlanningState = {};

function PlanningState.new( stateManager )
    local self = State.new():addInstance( 'PlanningState' );

    local factions;
    local inputStates = {
        ['attack'] = AttackInput.new(),
        ['movement'] = MovementInput.new(),
        ['interaction'] = InteractionInput.new(),
    }
    local activeInputState = inputStates['movement'];

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
            character:enqueueAction( Crouch.new( character ));
            stateManager:push( 'execution', factions, character );
        elseif scancode == 's' then
            character:clearActions();
            character:enqueueAction( StandUp.new( character ));
            stateManager:push( 'execution', factions, character );
        elseif scancode == 'p' then
            character:clearActions();
            character:enqueueAction( LieDown.new( character ));
            stateManager:push( 'execution', factions, character );
        elseif scancode == 'r' then
            character:clearActions();
            character:enqueueAction( Reload.new( character ));
            stateManager:push( 'execution', factions, character );
        elseif scancode == 'a' then
            character:clearActions();
            activeInputState = inputStates['attack'];
        elseif scancode == 'e' then
            character:clearActions();
            activeInputState = inputStates['interaction'];
        elseif scancode == 'm' then
            character:clearActions();
            activeInputState = inputStates['movement'];
        elseif scancode == 'space' then
            activeInputState = inputStates['movement'];
            factions:getFaction():nextCharacter();
        elseif scancode == 'backspace' then
            activeInputState = inputStates['movement'];
            factions:getFaction():prevCharacter();
        elseif scancode == 'return' then
            activeInputState = inputStates['movement'];
            factions:nextFaction();
        elseif scancode == 'i' then
            character:enqueueAction( OpenInventory.new( character, character:getTile() ));
            stateManager:push( 'execution', factions, character );
        elseif scancode == 'q' then
            ScreenManager.push( 'health', factions, character );
        end
    end

    function self:selectTile( tile, button )
        local character = factions:getFaction():getCurrentCharacter();
        if not tile or character:isDead() then
            return;
        end

        if button == 2 and tile:isOccupied() then
            factions:getFaction():selectCharacter( tile:getCharacter() );
            return;
        end

        activeInputState:request( tile, character );
        stateManager:push( 'execution', factions, character );
    end

    function self:getInputMode()
        return activeInputState;
    end

    function self:blocksInput()
        return false;
    end

    return self;
end

return PlanningState;
