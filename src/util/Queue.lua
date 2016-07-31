local Queue = {};

function Queue.new()
    local self = {};

    local queue = {};

    function self:enqueue( item )
        table.insert( queue, item );
    end

    function self:dequeue()
        return table.remove( queue, 1 );
    end

    function self:peek()
        return queue[1];
    end

    function self:isEmpty()
        return #queue == 0;
    end

    function self:getSize()
        return #queue;
    end

    function self:clear()
        queue = {};
    end

    function self:getItems()
        return queue;
    end

    return self;
end

return Queue;
