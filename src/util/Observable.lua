---
-- @module Observable
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Class = require( 'lib.Middleclass' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local Observable = Class( 'Observable' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function Observable:initialize()
    self.observers = {}
    self.index = 1
end

function Observable:observe( observer )
    assert( observer.receive, "Observer has to have a public receive method." )
    self.observers[self.index] = observer
    self.index = self.index + 1
    return self.index
end

function Observable:remove( index )
    self.observers[index] = nil
end

function Observable:publish( event, ... )
    for _, observer in pairs( self.observers ) do
        observer:receive( event, ... )
    end
end

return Observable
