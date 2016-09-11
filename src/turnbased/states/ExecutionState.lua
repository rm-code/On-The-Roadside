local State = require( 'src.turnbased.states.State' );
local ProjectileManager = require( 'src.items.weapons.ProjectileManager' );
local ExplosionManager = require( 'src.items.weapons.ExplosionManager' );
local Messenger = require( 'src.Messenger' );

local ExecutionState = {};

local AI_DELAY     = 0;
local PLAYER_DELAY = 0.15;

function ExecutionState.new( stateManager, factions )
    local self = State.new():addInstance( 'ExecutionState' );

    local character;
    local actionTimer = 0;
    local delay;

    function self:enter( ncharacter )
        character = ncharacter;
        delay = character:getFaction():isAIControlled() and AI_DELAY or PLAYER_DELAY;
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

        if actionTimer > delay then
            if character:hasEnqueuedAction() and character:canPerformAction() then
                character:performAction();

                if factions:getPlayerFaction():canSee( character:getTile() ) then
                    delay = PLAYER_DELAY;
                else
                    delay = AI_DELAY;
                end

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
