local StateManager = {};

function StateManager.new( states )
    local self = {};

    local stack = {};

    function self:update( dt )
        stack[#stack]:update( dt );
    end

    function self:keypressed( key )
        stack[#stack]:keypressed( key );
    end

    function self:mousepressed( mx, my, button )
        stack[#stack]:mousepressed( mx, my, button );
    end

    function self:processEvent( event )
        stack[#stack]:processEvent( event );
    end

    function self:switch( state, ... )
        stack = {};
        stack[#stack + 1] = states[state].new( self );
        stack[#stack]:enter( ... );
    end

    function self:push( state, ... )
        stack[#stack + 1] = states[state].new( self );
        stack[#stack]:enter( ... );
    end

    function self:pop()
        stack[#stack] = nil;
    end

    return self;
end

return StateManager;
