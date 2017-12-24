---
-- @module Queue
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Queue = Class( 'Queue' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function Queue:initialize()
    self.queue = {}
end

function Queue:enqueue( item )
    table.insert( self.queue, item )
end

function Queue:dequeue()
    return table.remove( self.queue, 1 )
end

function Queue:peek()
    return self.queue[1]
end

function Queue:isEmpty()
    return #self.queue == 0
end

function Queue:getSize()
    return #self.queue
end

function Queue:clear()
    self.queue = {}
end

function Queue:getItems()
    return self.queue
end

return Queue
