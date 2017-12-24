---
-- @module OpenInventory
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Action = require( 'src.characters.actions.Action' )
local ScreenManager = require( 'lib.screenmanager.ScreenManager' )

-- ------------------------------------------------
-- Required Module
-- ------------------------------------------------

local OpenInventory = Action:subclass( 'OpenInventory' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function OpenInventory:initialize( character, target )
    Action.initialize( self, character, target, 0 )
end

function OpenInventory:perform()
    ScreenManager.push( 'inventory', self.character, self.target )
    return true
end

return OpenInventory
