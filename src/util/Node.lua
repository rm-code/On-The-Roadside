---
-- A node to be used in a linked list.
-- @module Node
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Node = Class( 'Node' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function Node:initialize( object )
    self.object = object
end

function Node:linkNext( node )
    self.next = node
end

function Node:linkPrev( node )
    self.prev = node
end

function Node:getNext()
    return self.next
end

function Node:getPrev()
    return self.prev
end

function Node:getObject()
    return self.object
end

return Node
