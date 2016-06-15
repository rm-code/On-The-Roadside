local StateManager = require( 'src.turnbased.StateManager' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local TurnManager = {};

function TurnManager.new( map )
    local self = {};

    local states = {
        attack    = require( 'src.turnbased.AttackState' ),
        interact  = require( 'src.turnbased.InteractionState' ),
        execution = require( 'src.turnbased.ExecutionState' ),
        movement  = require( 'src.turnbased.MovementState' )
    }

    local stateManager = StateManager.new( states );
    stateManager:switch( 'movement', { map = map } );

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
        stateManager:mousepressed( mx, my, button );
    end

    return self;
end

return TurnManager;
