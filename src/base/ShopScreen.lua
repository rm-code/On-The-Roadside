---
-- @module ShopScreen
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local ScreenManager = require( 'lib.screenmanager.ScreenManager' )
local Screen = require( 'src.ui.screens.Screen' )

local Translator = require( 'src.util.Translator' )
local GridHelper = require( 'src.util.GridHelper' )

local UIContainer = require( 'src.ui.elements.UIContainer' )
local UIBackground = require( 'src.ui.elements.UIBackground' )
local UIOutlines = require( 'src.ui.elements.UIOutlines' )
local UIPaginatedList = require( 'src.ui.elements.lists.UIPaginatedList' )
local UIShopItem = require( 'src.base.UIShopItem' )
local UIObservableButton = require( 'src.ui.elements.UIObservableButton' )
local UILabel = require( 'src.ui.elements.UILabel' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ShopScreen = Screen:subclass( 'ShopScreen' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local UI_GRID_WIDTH  = 64
local UI_GRID_HEIGHT = 48

local INVENTORY_LIST_WIDTH = 20
local LABEL_HEIGHT = 1
local LABEL_Y = 1

local BASE_INVENTORY_X = 1
local BASE_INVENTORY_Y = 3
local BASE_INVENTORY_H = 40

local SHOP_INVENTORY_X = 3 + INVENTORY_LIST_WIDTH * 2
local SHOP_INVENTORY_Y = 3
local SHOP_INVENTORY_H = 40

local CHECKOUT_INVENTORY_X = 2 + INVENTORY_LIST_WIDTH
local SELL_INVENTORY_Y = 3
local SELL_INVENTORY_H = 20
local BUY_INVENTORY_Y = SELL_INVENTORY_Y + SELL_INVENTORY_H
local BUY_INVENTORY_H = 20

local CANCEL_BUTTON_WIDTH = 8
local CANCEL_BUTTON_HEIGHT = 1
local CANCEL_BUTTON_OFFSET_X = 1
local CANCEL_BUTTON_OFFSET_Y = UI_GRID_HEIGHT - 2

local CHECKOUT_BUTTON_WIDTH = 8
local CHECKOUT_BUTTON_HEIGHT = 1
local CHECKOUT_BUTTON_OFFSET_X = UI_GRID_WIDTH  - CHECKOUT_BUTTON_WIDTH - 1
local CHECKOUT_BUTTON_OFFSET_Y = UI_GRID_HEIGHT - 2

local CHECKOUT_LABEL_WIDTH = 8
local CHECKOUT_LABEL_HEIGHT = 1
local CHECKOUT_LABEL_OFFSET_X = CHECKOUT_INVENTORY_X
local CHECKOUT_LABEL_OFFSET_Y = UI_GRID_HEIGHT - 2

local BASE_INVENTORY_OUTLINE = BASE_INVENTORY_X + INVENTORY_LIST_WIDTH
local SHOP_INVENTORY_OUTLINE = 2 + INVENTORY_LIST_WIDTH * 2
local HEADER_OUTLINE = 2
local BOTTOM_OUTLINE = UI_GRID_HEIGHT - 3

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

---
-- Creates the outlines for this screen.
-- @tparam  number     x The origin of the screen along the x-axis.
-- @tparam  number     y The origin of the screen along the y-axis.
-- @treturn UIOutlines   The newly created UIOutlines instance.
--
local function generateOutlines( x, y )
    local outlines = UIOutlines( x, y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )

    -- Horizontal borders.
    for ox = 0, UI_GRID_WIDTH-1 do
        outlines:add( ox, 0                ) -- Top
        outlines:add( ox, UI_GRID_HEIGHT-1 ) -- Bottom
        outlines:add( ox, HEADER_OUTLINE )
        outlines:add( ox, BOTTOM_OUTLINE )
    end

    -- Vertical outlines.
    for oy = 0, UI_GRID_HEIGHT-1 do
        outlines:add( 0,               oy ) -- Left
        outlines:add( UI_GRID_WIDTH-1, oy ) -- Right
        outlines:add( BASE_INVENTORY_OUTLINE, oy )
        outlines:add( SHOP_INVENTORY_OUTLINE, oy )
    end

    outlines:refresh()
    return outlines
end

local function createBaseList( self, inventory )
    local buttonList = UIPaginatedList( self.x, self.y, BASE_INVENTORY_X, BASE_INVENTORY_Y, INVENTORY_LIST_WIDTH, BASE_INVENTORY_H )

    local itemList = {}
    local items = inventory:getItems()

    for i, item in ipairs( items ) do
        itemList[i] = UIShopItem( 0, 0, 0, 0, 'SELL_ITEM', item )
        itemList[i]:observe( self )
    end

    buttonList:setItems( itemList )

    return buttonList
end

local function createShopList( self )
    local buttonList = UIPaginatedList( self.x, self.y, SHOP_INVENTORY_X, SHOP_INVENTORY_Y, INVENTORY_LIST_WIDTH, SHOP_INVENTORY_H )
    buttonList:setItems( {} )
    return buttonList
end

local function createBuyList( self )
    local list = UIPaginatedList( self.x, self.y, CHECKOUT_INVENTORY_X, BUY_INVENTORY_Y, INVENTORY_LIST_WIDTH, BUY_INVENTORY_H )
    list:setItems( {} )
    return list
end

local function createSellList( self )
    local list = UIPaginatedList( self.x, self.y, CHECKOUT_INVENTORY_X, SELL_INVENTORY_Y, INVENTORY_LIST_WIDTH, SELL_INVENTORY_H )
    list:setItems( {} )
    return list
end

local function createCancelButton( self )
    local rx, ry, w, h = CANCEL_BUTTON_OFFSET_X, CANCEL_BUTTON_OFFSET_Y, CANCEL_BUTTON_WIDTH, CANCEL_BUTTON_HEIGHT
    local button = UIObservableButton( self.x, self.y, rx, ry, w, h, Translator.getText( 'general_cancel' ), 'left', 'CANCEL' )
    button:observe( self )
    return button
end

local function createCheckoutButton( self )
    local rx, ry, w, h = CHECKOUT_BUTTON_OFFSET_X, CHECKOUT_BUTTON_OFFSET_Y, CHECKOUT_BUTTON_WIDTH, CHECKOUT_BUTTON_HEIGHT
    local button = UIObservableButton( self.x, self.y, rx, ry, w, h, Translator.getText( 'base_shop_checkout' ), 'left', 'CHECKOUT' )
    button:observe( self )
    return button
end

local function createLabel( x, y, rx, ry, w, h, txt, color )
    return UILabel( x, y, rx, ry, w, h, Translator.getText( txt ), color )
end

local function createPriceLabel( self )
    local rx, ry, w, h = CHECKOUT_LABEL_OFFSET_X, CHECKOUT_LABEL_OFFSET_Y, CHECKOUT_LABEL_WIDTH, CHECKOUT_LABEL_HEIGHT
    local balance = self.lists.sellInventory:getItemCount() - self.lists.buyInventory:getItemCount()
    local txt = string.format( Translator.getText( 'base_shop_checkout_label' ), balance )
    local color = balance < 0 and 'shop_balance_negative' or 'shop_balance_positive'
    return UILabel( self.x, self.y, rx, ry, w, h, txt, color )
end

local function moveShopItem( source, target, item, msg, type )
    source:removeItem( item )
    target:addItem( item )
    item:setMessage( msg )
    item:setType( type )
end

local function commitItems( source, target, msg, type )
    local items = {}
    for i, uiItem in ipairs( source:getItems() ) do
        uiItem:setMessage( msg )
        uiItem:setType( type )
        items[i] = uiItem
    end
    target:addItems( items )

    -- Clear source list.
    source:setItems( {} )
end

local function commitCheckout( base, shop, buy, sell )
    commitItems( buy, base, 'SELL_ITEM', UIShopItem.TYPE_NONE )
    commitItems( sell, shop, 'BUY_ITEM', UIShopItem.TYPE_NONE )
end

local function cancel( base, shop, buy, sell )
    commitItems( sell, base, 'SELL_ITEM', UIShopItem.TYPE_NONE )
    commitItems( buy, shop, 'BUY_ITEM', UIShopItem.TYPE_NONE )

    ScreenManager.switch( 'base' )
end

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function ShopScreen:initialize( baseInventory )
    self.x, self.y = GridHelper.centerElement( UI_GRID_WIDTH, UI_GRID_HEIGHT )

    self.outlines = generateOutlines( self.x, self.y )
    self.background = UIBackground( self.x, self.y, 0, 0, UI_GRID_WIDTH, UI_GRID_HEIGHT )

    self.container = UIContainer()

    self.lists = {
        baseInventory = createBaseList( self, baseInventory ),
        buyInventory  = createBuyList( self ),
        sellInventory = createSellList( self ),
        shopInventory = createShopList( self ),
    }

    self.baseLabel = createLabel( self.x, self.y, BASE_INVENTORY_X, LABEL_Y, INVENTORY_LIST_WIDTH, LABEL_HEIGHT, 'ui_base_inventory', 'ui_inventory_headers' )
    self.checkoutLabel = createLabel( self.x, self.y, CHECKOUT_INVENTORY_X, LABEL_Y, INVENTORY_LIST_WIDTH, LABEL_HEIGHT, 'base_shop_checkout', 'ui_inventory_headers' )
    self.shopLabel = createLabel( self.x, self.y, SHOP_INVENTORY_X, LABEL_Y, INVENTORY_LIST_WIDTH, LABEL_HEIGHT, 'base_shop_button', 'ui_inventory_headers' )

    self.cancelButton = createCancelButton( self )
    self.checkoutButton = createCheckoutButton( self )

    self.priceLabel = createPriceLabel( self )

    self.container:register( self.lists.baseInventory )
    self.container:register( self.lists.buyInventory )
    self.container:register( self.lists.sellInventory )
    self.container:register( self.lists.shopInventory )

    self.container:register( self.cancelButton )
    self.container:register( self.checkoutButton )
end

function ShopScreen:receive( msg, ... )
    if msg == 'SELL_ITEM' then
        local shopItem = ...
        moveShopItem( self.lists.baseInventory, self.lists.sellInventory, shopItem, 'UNSELL_ITEM', UIShopItem.TYPE_SELL )
        self.priceLabel = createPriceLabel( self )
    elseif msg == 'BUY_ITEM' then
        local shopItem = ...
        moveShopItem( self.lists.shopInventory, self.lists.buyInventory, shopItem, 'UNBUY_ITEM', UIShopItem.TYPE_BUY )
        self.priceLabel = createPriceLabel( self )
    elseif msg == 'UNSELL_ITEM' then
        local shopItem = ...
        moveShopItem( self.lists.sellInventory, self.lists.baseInventory, shopItem, 'SELL_ITEM', UIShopItem.TYPE_NONE )
        self.priceLabel = createPriceLabel( self )
    elseif msg == 'UNBUY_ITEM' then
        local shopItem = ...
        moveShopItem( self.lists.buyInventory, self.lists.shopInventory, shopItem, 'BUY_ITEM', UIShopItem.TYPE_NONE )
        self.priceLabel = createPriceLabel( self )
    elseif msg == 'CHECKOUT' then
        commitCheckout( self.lists.baseInventory, self.lists.shopInventory, self.lists.buyInventory, self.lists.sellInventory )
        self.priceLabel = createPriceLabel( self )
    elseif msg == 'CANCEL' then
        cancel( self.lists.baseInventory, self.lists.shopInventory, self.lists.buyInventory, self.lists.sellInventory )
    end
end

function ShopScreen:update()
    self.container:update()
end

function ShopScreen:draw()
    self.background:draw()
    self.outlines:draw()

    self.baseLabel:draw()
    self.checkoutLabel:draw()
    self.shopLabel:draw()

    self.lists.baseInventory:draw()
    self.lists.buyInventory:draw()
    self.lists.sellInventory:draw()
    self.lists.shopInventory:draw()

    self.cancelButton:draw()
    self.checkoutButton:draw()

    self.priceLabel:draw()
end

function ShopScreen:keypressed( _, scancode )
    love.mouse.setVisible( false )

    if scancode == 'escape' then
        ScreenManager.switch( 'base' )
        return
    end

    if scancode == 'tab' then
        self.container:next()
    end

    if scancode == 'up' then
        self.container:command( 'up' )
    elseif scancode == 'down' then
        self.container:command( 'down' )
    elseif scancode == 'left' then
        self.container:command( 'left' )
    elseif scancode == 'right' then
        self.container:command( 'right' )
    elseif scancode == 'return' then
        self.container:command( 'activate' )
    end
end

function ShopScreen:mousereleased()
    self.container:mousecommand( 'activate' )
end

function ShopScreen:mousemoved()
    love.mouse.setVisible( true )
end

return ShopScreen
