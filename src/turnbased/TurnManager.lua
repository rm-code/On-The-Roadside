local StateManager = require( 'src.turnbased.states.StateManager' );

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

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:update( dt )
        stateManager:update( dt );
    end

    -- ------------------------------------------------
    -- Input Events
    -- ------------------------------------------------

    function self:keypressed( key )
        stateManager:keypressed( key );
    end

    function self:mousepressed( mx, my, button )
        stateManager:selectTile( map:getTileAt( mx, my ), button );
    end

    return self;
end

return TurnManager;
