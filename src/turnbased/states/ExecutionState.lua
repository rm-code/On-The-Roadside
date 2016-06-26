local State = require( 'src.turnbased.states.State' );
local CharacterManager = require( 'src.characters.CharacterManager' );
local ProjectileManager = require( 'src.items.weapons.ProjectileManager' );

local ExecutionState = {};

local TURN_STEP_DELAY = 0.15;

function ExecutionState.new( stateManager )
    local self = State.new();

    local actionTimer = 0;

    function self:update( dt )
        if not ProjectileManager.isDone() then
            ProjectileManager.update( dt );
            return;
        end

        local character = CharacterManager:getCurrentCharacter();
        if actionTimer > TURN_STEP_DELAY then
            if character:canPerformAction() then
                character:performAction();
                actionTimer = 0;
            else
                stateManager:pop();
            end
            CharacterManager.removeDeadActors();
        end
        actionTimer = actionTimer + dt;
    end

    return self;
end

return ExecutionState;
