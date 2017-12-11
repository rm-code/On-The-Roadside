---
-- @module StateManager
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local StateManager = Class( 'StateManager' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function StateManager:initialize( states )
    self.stack = {}
    self.states = states
end

function StateManager:switch( state, ... )
    self.stack = {}
    self:push( state, ... )
end

function StateManager:push( state, ... )
    self.stack[#self.stack + 1] = self.states[state]( self )

    if self.stack[#self.stack].enter then
        self.stack[#self.stack]:enter( ... )
    end
end

function StateManager:pop()
    self.stack[#self.stack] = nil
end

function StateManager:update( dt )
    self.stack[#self.stack]:update( dt )
end

function StateManager:input( input )
    self.stack[#self.stack]:input( input )
end

function StateManager:selectTile( tile, button )
    self.stack[#self.stack]:selectTile( tile, button )
end

function StateManager:blocksInput()
    return self.stack[#self.stack]:blocksInput()
end

function StateManager:getState()
    return self.stack[#self.stack]
end

return StateManager
