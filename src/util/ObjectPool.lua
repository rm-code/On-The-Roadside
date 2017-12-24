---
-- @module ObjectPool
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )
local Queue = require( 'src.util.Queue' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ObjectPool = Class( 'ObjectPool' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function ObjectPool:initialize( class )
    self.class = class
    self.queue = Queue()
end

function ObjectPool:request( ... )
    local object

    if self.queue:isEmpty() then
        object = self.class()
        self.queue:enqueue( object )
    end

    object = self.queue:dequeue()
    object:setParameters( ... )
    return object
end

function ObjectPool:deposit( object )
    if object:isInstanceOf( self.class ) then
        object:clear()
        self.queue:enqueue( object )
    else
        error( string.format( "Object (%s) isn't an instance of the class type required for this ObjectPool (%s).", object, self.class ))
    end
end

return ObjectPool
