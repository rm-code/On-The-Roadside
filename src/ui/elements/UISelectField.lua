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

local UISelectField = UIElement:subclass( 'UISelectField' )

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UISelectField:initialize( px, py, x, y, w, h, nlabel, nlistOfValues, ncallback, default )
    UIElement.initialize( self, px, py, x, y, w, h )

    self.label = nlabel
    self.listOfValues = nlistOfValues
    self.callback = ncallback
    self.current = default or 1
end

function UISelectField:draw()
    local tw, th = TexturePacks.getTileDimensions()

    -- Draw the label on the left side of the SelectField.
    TexturePacks.setColor( self:hasFocus() and 'ui_select_field_hot' or 'ui_select_field' )
    love.graphics.print( self.label, self.ax * tw, self.ay * th )

    -- Draw the current value on right side of the SelectField.
    local value = string.format( '<%s>', self.listOfValues[self.current].displayTextID )
    local width = TexturePacks.getFont():measureWidth( value )
    love.graphics.print( value, self.ax * tw + self.w * th - width, self.ay * th )
    TexturePacks.resetColor()
end

---
-- Select the next value from the list of values and pass it to the callback.
--
function UISelectField:next()
    self.current = self.current == #self.listOfValues and 1 or self.current + 1
    self.callback( self.listOfValues[self.current].value )
end

---
-- Select the previous value from the list of values and pass it to the callback.
--
function UISelectField:prev()
    self.current = self.current == 1 and #self.listOfValues or self.current - 1
    self.callback( self.listOfValues[self.current].value )
end

function UISelectField:command( cmd )
    if cmd == 'left' then
        self:prev()
    elseif cmd == 'right' then
        self:next()
    end
end

function UISelectField:mousereleased( _, _, _, _ )
    self:next()
end

return UISelectField
