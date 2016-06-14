local StateManager = {};

function StateManager.new( states )
    local self = {};

    local activeState;

    function self:update( dt )
        activeState:update( dt );
    end

    function self:keypressed( key )
        activeState:keypressed( key );
    end

    function self:mousepressed( mx, my, button )
        activeState:mousepressed( mx, my, button );
    end

    function self:processEvent( event )
        activeState:processEvent( event );
    end

    function self:switch( state, ... )
        if activeState then
            activeState:leave();
        end

        print( 'Switching to ' .. state );
        activeState = states[state].new( self );
        activeState:enter( ... );
    end

    return self;
end

return StateManager;
