local State = require( 'src.turnbased.states.State' );
local ProjectileManager = require( 'src.items.weapons.ProjectileManager' );
local ExplosionManager = require( 'src.items.weapons.ExplosionManager' );
local Log = require( 'src.util.Log' );

local ExecutionState = {};

local AI_DELAY     = 0;
local PLAYER_DELAY = 0.15;

function ExecutionState.new( stateManager )
    local self = State.new():addInstance( 'ExecutionState' );

    local character;
    local actionTimer = 0;
    local delay;
    local factions;

    function self:enter( nfactions, ncharacter )
        factions = nfactions;
        character = ncharacter;
        delay = character:getFaction():isAIControlled() and AI_DELAY or PLAYER_DELAY;
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

        if character:isDead() then
            Log.debug( string.format( 'Character (%s) is dead. Stopping execution', tostring( character )), 'ExecutionState' );
            stateManager:pop();
            return;
        end

        if actionTimer > delay then
            if character:hasEnqueuedAction() then
                character:performAction();

                if factions:getPlayerFaction():canSee( character:getTile() ) then
                    delay = PLAYER_DELAY;
                else
                    delay = AI_DELAY;
                end

                actionTimer = 0;
            else
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
