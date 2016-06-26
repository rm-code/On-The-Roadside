local State = require( 'src.turnbased.State' );
local CharacterManager = require( 'src.characters.CharacterManager' );
local ProjectileManager = require( 'src.items.weapons.ProjectileManager' );

local ExecutionState = {};

local TURN_STEP_DELAY = 0.15;

function ExecutionState.new( stateManager )
    local self = State.new();

    local actionTimer = 0;
    local map;

    function self:enter( params )
        map = params.map;
    end

    function self:update( dt )
        if not ProjectileManager.isDone() then
            ProjectileManager.update( dt, map );
            return;
        end

        local character = CharacterManager:getCurrentCharacter();
        if actionTimer > TURN_STEP_DELAY then
            if character:canPerformAction() then
                character:performAction();
                actionTimer = 0;
            else
                stateManager:switch( 'movement', { map = map } );
            end
            CharacterManager.removeDeadActors();
        end
        actionTimer = actionTimer + dt;
    end

    return self;
end

return ExecutionState;
