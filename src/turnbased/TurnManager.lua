local StateManager = require( 'src.turnbased.StateManager' );

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local TILE_SIZE = require( 'src.constants.TileSize' );

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
        local tx, ty = math.floor( mx / TILE_SIZE ), math.floor( my / TILE_SIZE );
        stateManager:mousepressed( tx, ty, button );
    end

    return self;
end

return TurnManager;
