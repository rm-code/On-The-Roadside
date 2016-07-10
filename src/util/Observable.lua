local Object = require( 'src.Object' );

local Observable = {};

function Observable.new()
    local self = Object.new():addInstance( 'Observable' );

    local observers = {};
    local index = 1;

    function self:observe( observer )
        assert( observer.receive, "Observer has to have a public receive method." );
        observers[index] = observer;
        index = index;
        return index;
    end

    function self:remove( index )
        observers[index] = nil;
    end

    function self:publish( event, ... )
        for _, observer in pairs( observers ) do
            observer:receive( event, ... );
        end
    end

    return self;
end

return Observable;
