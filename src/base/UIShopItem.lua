---
-- @module UIShopItem
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Translator = require( 'src.util.Translator' )

local UIElement = require( 'src.ui.elements.UIElement' )
local UIObservableButton = require( 'src.ui.elements.UIObservableButton' )
local UILabel = require( 'src.ui.elements.UILabel' )

local Observable = require( 'src.util.Observable' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIShopItem = UIElement:subclass( 'UIShopItem' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

UIShopItem.TYPE_NONE = 0
UIShopItem.TYPE_SELL = 1
UIShopItem.TYPE_BUY  = 2

local UI_GRID_WIDTH = 16
local UI_GRID_HEIGHT = 1

local COLORS = {}
COLORS.BUY = {}
COLORS.BUY.HOT = 'shopitem_buy_hot'
COLORS.BUY.FOCUS = 'shopitem_buy_focus'
COLORS.BUY.DEFAULT = 'shopitem_buy'
COLORS.BUY.INACTIVE_HOT = 'ui_button_inactive_hot'
COLORS.BUY.INACTIVE_FOCUS = 'ui_button_inactive_focus'
COLORS.BUY.INACTIVE_DEFAULT = 'ui_button_inactive'

COLORS.SELL = {}
COLORS.SELL.HOT = 'shopitem_sell_hot'
COLORS.SELL.FOCUS = 'shopitem_sell_focus'
COLORS.SELL.DEFAULT = 'shopitem_sell'
COLORS.SELL.INACTIVE_HOT = 'ui_button_inactive_hot'
COLORS.SELL.INACTIVE_FOCUS = 'ui_button_inactive_focus'
COLORS.SELL.INACTIVE_DEFAULT = 'ui_button_inactive'

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UIShopItem:initialize( ox, oy, rx, ry, msg, item )
    UIElement.initialize( self, ox, oy, rx, ry, UI_GRID_WIDTH, UI_GRID_HEIGHT )

    self.observable = Observable()

    self.msg = msg
    self.item = item
    self.type = UIShopItem.TYPE_NONE

    self.button = UIObservableButton( self.ax, self.ay, 0, 0, 10, 1, Translator.getText( item:getID() ), 'left', 'BUTTON_PRESSED' )
    self.button:observe( self )
    self.button:setIcon( item:getID() )
    self.button:setIconColorID( item:getID() )

    self.label = UILabel( self.ax, self.ay, 0, 0, self.w, 1, self.item:getItemCount(), 'ui_button', 'right' )

    self:addChild( self.button )
    self:addChild( self.label )
end

function UIShopItem:receive( msg )
    if msg == 'BUTTON_PRESSED' then
        self.observable:publish( self.msg, self )
    end
end

function UIShopItem:observe( observer )
    self.observable:observe( observer )
end

function UIShopItem:draw()
    self.button:draw()
    self.label:draw()
end

function UIShopItem:update()
    self.button:update()
end

function UIShopItem:command( cmd )
    self.button:command( cmd )
end

function UIShopItem:mousecommand( cmd )
    self.button:mousecommand( cmd )
end

function UIShopItem:setFocus( focus )
    for i = 1, #self.children do
        self.children[i]:setFocus( focus )
    end
end

function UIShopItem:setMessage( msg )
    self.msg = msg
end

function UIShopItem:setType( type )
    self.type = type

    if self.type == UIShopItem.TYPE_BUY then
        self.button:setColors( COLORS.BUY )
    elseif self.type == UIShopItem.TYPE_SELL then
        self.button:setColors( COLORS.SELL )
    elseif self.type == UIShopItem.TYPE_NONE then
        self.button:setDefaultColors()
    end
end

return UIShopItem
