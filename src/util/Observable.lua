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
end

function Observable:observe( observer )
    assert( observer.receive, "Observer has to have a public receive method." )
    self.observers[observer] = true
end

function Observable:remove( observer )
    self.observers[observer] = nil
end

function Observable:publish( event, ... )
    for observer, _ in pairs( self.observers ) do
        observer:receive( event, ... )
    end
end

return Observable
