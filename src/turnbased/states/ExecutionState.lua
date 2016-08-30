local State = require( 'src.turnbased.states.State' );
local ProjectileManager = require( 'src.items.weapons.ProjectileManager' );
local ExplosionManager = require( 'src.items.weapons.ExplosionManager' );
local Messenger = require( 'src.Messenger' );

local ExecutionState = {};

local TURN_STEP_DELAY = 0.15;

function ExecutionState.new( stateManager )
    local self = State.new():addInstance( 'ExecutionState' );

    local character;
    local actionTimer = 0;

    function self:enter( ncharacter )
        character = ncharacter;
        Messenger.publish( 'START_EXECUTION' );
    end

    function self:update( dt )
        if not ProjectileManager.isDone() then
            ProjectileManager.update( dt );
            return;
        end

        if not ExplosionManager.isDone() then
            ExplosionManager.update( dt );
            return;
        end

        if actionTimer > TURN_STEP_DELAY then
            if character:hasEnqueuedAction() and character:canPerformAction() then
                character:performAction();
                actionTimer = 0;
            else
                Messenger.publish( 'END_EXECUTION' );
                stateManager:pop();
            end
        end
        actionTimer = actionTimer + dt;
    end

    function self:blocksInput()
        return true;
    end

    return self;
end

return ExecutionState;
