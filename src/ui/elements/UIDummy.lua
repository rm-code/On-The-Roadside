---
-- @module UIDummy
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UIElement = require( 'src.ui.elements.UIElement' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIDummy = UIElement:subclass( 'UIDummy' )

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UIDummy:initialize( px, py, x, y, w, h )
    UIElement.initialize( self, px, py, x, y, w, h )
end

return UIDummy
