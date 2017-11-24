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
-- Private Methods
-- ------------------------------------------------

local function selectColor( self )
    if love.mouse.isVisible() and self:isMouseOver() then
        return 'ui_select_field_hot'
    elseif self:hasFocus() then
        return 'ui_select_field_hot'
    end
    return 'ui_select_field'
end

-- ------------------------------------------------
-- Public Methods
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
    TexturePacks.setColor( selectColor( self ))
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
    elseif cmd == 'right' or cmd == 'activate' then
        self:next()
    end
end

return UISelectField
