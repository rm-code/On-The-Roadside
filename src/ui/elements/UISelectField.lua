---
-- @module UISelectField
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UIElement = require( 'src.ui.elements.UIElement' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UISelectField = {}

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UISelectField.new( px, py, x, y, w, h )
    local self = UIElement.new( px, py, x, y, w, h ):addInstance( 'UISelectField' )

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local label
    local listOfValues
    local callback
    local current

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:init( nlabel, nlistOfValues, ncallback, default )
        label = nlabel
        listOfValues = nlistOfValues
        callback = ncallback
        current = default or 1
    end

    function self:draw()
        local tw, th = TexturePacks.getTileDimensions()
        -- Draw the label on the left side of the SelectField.
        TexturePacks.setColor( self:hasFocus() and 'ui_select_field_hot' or 'ui_select_field' )
        love.graphics.print( label, self.ax * tw, self.ay * th )

        -- Draw the current value on right side of the SelectField.
        local value = string.format( '<%s>', listOfValues[current].displayTextID )
        local width = TexturePacks.getFont():measureWidth( value )
        love.graphics.print( value, self.ax * tw + self.w * th - width, self.ay * th )
        TexturePacks.resetColor()
    end

    ---
    -- Select the next value from the list of values and pass it to the callback.
    --
    function self:next()
        current = current == #listOfValues and 1 or current + 1
        callback( listOfValues[current].value )
    end

    ---
    -- Select the previous value from the list of values and pass it to the callback.
    --
    function self:prev()
        current = current == 1 and #listOfValues or current - 1
        callback( listOfValues[current].value )
    end

    function self:command( cmd )
        if cmd == 'left' then
            self:prev()
        elseif cmd == 'right' then
            self:next()
        end
    end

    function self:mousereleased( _, _, _, _ )
        self:next()
    end

    return self
end

return UISelectField
