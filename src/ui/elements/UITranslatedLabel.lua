---
-- @module UITranslatedLabel
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UILabel = require( 'src.ui.elements.UILabel' )
local Translator = require( 'src.util.Translator' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UITranslatedLabel = {}

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UITranslatedLabel.new( px, py, x, y, w, h, textID, color )
    local self = UILabel.new( px, py, x, y, w, h, Translator.getText( textID ), color ):addInstance( 'UITranslatedLabel' )

    function self:setTextID( ntextID )
        self:setText( Translator.getText( ntextID ))
    end

    return self
end

return UITranslatedLabel
