local StateManager = {};

function StateManager.new( states )
    local self = {};

    local stack = {};

    function self:blocksInput()
        return stack[#stack]:blocksInput();
    end

    function self:update( dt )
        stack[#stack]:update( dt );
    end

    function self:keypressed( key, scancode, isrepeat )
        stack[#stack]:keypressed( key, scancode, isrepeat )
    end

    function self:selectTile( tile, button )
        stack[#stack]:selectTile( tile, button );
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

    function self:getState()
        return stack[#stack];
    end

    return self;
end

return StateManager;
