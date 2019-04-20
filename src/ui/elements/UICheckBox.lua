---
-- @module UICheckBox
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UIElement = require( 'src.ui.elements.UIElement' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local Observable = require( 'src.util.Observable' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UICheckBox = UIElement:subclass( 'UIButton' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local ICON_CHECKED = 'ui_checkbox_checked'
local ICON_UNCHECKED = 'ui_checkbox_unchecked'

local LABEL_OFFSET_X = 2

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

local function selectColor( self )
    if love.mouse.isVisible() and self:isMouseOver() then
        return 'ui_button_hot'
    elseif self:hasFocus() then
        return 'ui_button_focus'
    end
    return 'ui_button'
end

local function drawIcon( px, py, icon )
    love.graphics.draw( TexturePacks.getTileset():getSpritesheet(), icon, px, py )
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function UICheckBox:initialize( px, py, x, y, w, h, checkedEventMsg, uncheckedEventMsg, label )
    UIElement.initialize( self, px, py, x, y, w, h )

    self.checkedEventMsg = checkedEventMsg
    self.uncheckedEventMsg = uncheckedEventMsg
    self.label = label

    self.observable = Observable()

    self.iconChecked = TexturePacks.getSprite( ICON_CHECKED )
    self.iconUnchecked = TexturePacks.getSprite( ICON_UNCHECKED )

    self.checked = false
end


function UICheckBox:draw()
    local tw, th = TexturePacks.getTileDimensions()

    TexturePacks.setColor( selectColor( self ))

    -- Draw text.
    if self.label then
        love.graphics.print( self.label, ( self.ax + LABEL_OFFSET_X ) * tw, self.ay * th )
    end

    drawIcon( self.ax * tw, self.ay * th, self.checked and self.iconChecked or self.iconUnchecked )

    TexturePacks.resetColor()
end

function UICheckBox:activate()
    self.checked = not self.checked

    if self.checked then
        self.observable:publish( self.checkedEventMsg )
    else
        self.observable:publish( self.uncheckedEventMsg )
    end
end

function UICheckBox:command( cmd )
    if cmd == 'activate' then
        self:activate()
    end
end

function UICheckBox:mousecommand( cmd )
    self:command( cmd )
end

function UICheckBox:observe( observer )
    self.observable:observe( observer )
end

return UICheckBox
