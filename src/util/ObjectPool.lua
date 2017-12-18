local Object = require( 'src.Object' );
local Queue = require( 'src.util.Queue' );

local ObjectPool = {};

function ObjectPool.new( class )
    local self = Object.new():addInstance( 'ObjectPool' );

    local queue = Queue()

    function self:request( ... )
        local object;

        if queue:isEmpty() then
            object = class()
            queue:enqueue( object );
        end

        object = queue:dequeue();
        object:setParameters( ... )
        return object;
    end

    function self:deposit( object )
        if object:isInstanceOf( class ) then
            object:clear();
            queue:enqueue( object );
        else
            error( string.format( "Object (%s) isn't an instance of the class type required for this ObjectPool (%s).", object, class ))
        end
    end

    return self;
end

return ObjectPool;
