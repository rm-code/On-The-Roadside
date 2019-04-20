---
-- @module UIObservableButton
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UIButton = require( 'src.ui.elements.UIButton' )
local Observable = require( 'src.util.Observable' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIObservableButton = UIButton:subclass( 'UIObservableButton' )

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function UIObservableButton:initialize( px, py, x, y, w, h, text, alignMode, msg, ... )
    UIButton.initialize( self, px, py, x, y, w, h, nil, text, alignMode )

    self.msg = msg
    self.args = { ... }

    self.observable = Observable()
end

function UIObservableButton:activate()
    self.observable:publish( self.msg, unpack( self.args ))
end

function UIObservableButton:command( cmd )
    if cmd == 'activate' then
        self:activate()
    end
end

function UIObservableButton:observe( observer )
    self.observable:observe( observer )
end

return UIObservableButton
