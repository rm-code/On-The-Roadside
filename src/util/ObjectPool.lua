local Object = require( 'src.Object' );
local Queue = require( 'src.util.Queue' );

local ObjectPool = {};

function ObjectPool.new( class, type )
    local self = Object.new():addInstance( 'ObjectPool' );

    local queue = Queue()

    function self:request( ... )
        local object;

        if queue:isEmpty() then
            object = class.new();
            queue:enqueue( object );
        end

        object = queue:dequeue();
        object:setParameters( ... )
        return object;
    end

    function self:deposit( object )
        if type and object:instanceOf( type ) then
            object:clear();
            queue:enqueue( object );
        else
            local list = "";
            for i, v in pairs( object.__instances ) do
                list = list .. v;
                if i ~= #object.__instances then
                    list = list .. ', ';
                end
            end
            error( string.format( "Object (%s) isn't an instance of the class type required for this ObjectPool (%s).", list, type ));
        end
    end

    return self;
end

return ObjectPool;
