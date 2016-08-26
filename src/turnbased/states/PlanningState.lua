local ScreenManager = require( 'lib.screenmanager.ScreenManager' );
local State = require( 'src.turnbased.states.State' );
local Reload = require( 'src.characters.actions.Reload' );
local StandUp = require( 'src.characters.actions.StandUp' );
local Crouch = require( 'src.characters.actions.Crouch' );
local LieDown = require( 'src.characters.actions.LieDown' );

local AttackInput = require( 'src.turnbased.helpers.AttackInput' );
local MovementInput = require( 'src.turnbased.helpers.MovementInput' );
local InteractionInput = require( 'src.turnbased.helpers.InteractionInput' );

local PlanningState = {};

function PlanningState.new( stateManager )
    local self = State.new():addInstance( 'PlanningState' );

    local factions;
    local inputStates = {
        ['attack'] = AttackInput.new( stateManager ),
        ['movement'] = MovementInput.new( stateManager ),
        ['interaction'] = InteractionInput.new( stateManager ),
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

    function self:keypressed( key )
        local character = factions:getFaction():getCurrentCharacter();
        if character:isDead() then
            return;
        end

        if key == 'right' then
            character:getEquipment():getWeapon():selectNextFiringMode();
        elseif key == 'left' then
            character:getEquipment():getWeapon():selectPrevFiringMode();
        elseif key == 'c' then
            character:clearActions();
            character:enqueueAction( Crouch.new( character ));
            stateManager:push( 'execution', character );
        elseif key == 's' then
            character:clearActions();
            character:enqueueAction( StandUp.new( character ));
            stateManager:push( 'execution', character );
        elseif key == 'p' then
            character:clearActions();
            character:enqueueAction( LieDown.new( character ));
            stateManager:push( 'execution', character );
        elseif key == 'r' then
            character:clearActions();
            character:enqueueAction( Reload.new( character ));
            stateManager:push( 'execution', character );
        elseif key == 'a' then
            character:clearActions();
            activeInputState = inputStates['attack'];
        elseif key == 'e' then
            character:clearActions();
            activeInputState = inputStates['interaction'];
        elseif key == 'm' then
            character:clearActions();
            activeInputState = inputStates['movement'];
        elseif key == 'space' then
            activeInputState = inputStates['movement'];
            factions:getFaction():nextCharacter();
        elseif key == 'backspace' then
            activeInputState = inputStates['movement'];
            factions:getFaction():prevCharacter();
        elseif key == 'return' then
            activeInputState = inputStates['movement'];
            factions:nextFaction();
        elseif key == 'i' then
            ScreenManager.push( 'inventory', character );
        end
    end

    function self:selectTile( tile, button )
        if not tile or factions:getFaction():getCurrentCharacter():isDead() then
            return;
        end

        if button == 2 and tile:isOccupied() then
            factions:getFaction():selectCharacter( tile:getCharacter() );
            return;
        end

        activeInputState:request( tile, factions:getFaction():getCurrentCharacter() );
    end

    function self:getInputMode()
        return activeInputState;
    end

    return self;
end

return PlanningState;
