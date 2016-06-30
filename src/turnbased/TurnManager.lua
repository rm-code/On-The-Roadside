local StateManager = require( 'src.turnbased.states.StateManager' );
local SadisticAIDirector = require( 'src.characters.ai.SadisticAIDirector' );
local FactionManager = require( 'src.characters.FactionManager' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local TurnManager = {};

function TurnManager.new( map )
    local self = {};

    local states = {
        execution = require( 'src.turnbased.states.ExecutionState' ),
        planning = require( 'src.turnbased.states.PlanningState' )
    }

    local stateManager = StateManager.new( states );
    stateManager:push( 'planning', map );

    local sadisticAIDirector = SadisticAIDirector.new( map, stateManager );

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:update( dt )
        if FactionManager.getFaction():isAIControlled() and not stateManager:blocksInput() then
            sadisticAIDirector:update( dt );
        end

        stateManager:update( dt );
    end

    -- ------------------------------------------------
    -- Input Events
    -- ------------------------------------------------

    function self:keypressed( key )
        if FactionManager.getFaction():isAIControlled() or stateManager:blocksInput() then
            return;
        end

        stateManager:keypressed( key );
    end

    function self:mousepressed( mx, my, button )
        if FactionManager.getFaction():isAIControlled() or stateManager:blocksInput() then
            return;
        end

        stateManager:selectTile( map:getTileAt( mx, my ), button );
    end

    return self;
end

return TurnManager;
