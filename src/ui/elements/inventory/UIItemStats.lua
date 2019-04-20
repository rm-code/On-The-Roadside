---
-- @module UIItemStats
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local UIElement = require( 'src.ui.elements.UIElement' )
local TexturePacks = require( 'src.ui.texturepacks.TexturePacks' )
local Translator = require( 'src.util.Translator' )
local UIScrollArea = require( 'src.ui.elements.UIScrollArea' )
local ItemStack = require( 'src.inventory.ItemStack' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIItemStats = UIElement:subclass( 'UIItemStats' )

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local ITEM_TYPES = require('src.constants.ITEM_TYPES')
local WEAPON_TYPES = require( 'src.constants.WEAPON_TYPES' )

local COLUMN_1 = 0
local COLUMN_2 = 10
local COLUMN_3 = 22
local COLUMN_4 = 30

local WEAPON_COLUMN_MODE =  0
local WEAPON_COLUMN_AP   = 20
local WEAPON_COLUMN_ACC  = 25
local WEAPON_COLUMN_DMG  = 30

local VERTICAL_DESCRIPTION_OFFSET = 12

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UIItemStats:initialize( px, py, x, y, w, h )
    UIElement.initialize( self, px, py, x, y, w, h )

    self.nameColor  = TexturePacks.getColor( 'ui_inventory_stats_name' )
    self.typeColor  = TexturePacks.getColor( 'ui_inventory_stats_type' )
    self.valueColor = TexturePacks.getColor( 'ui_inventory_stats_value' )
    self.descColor  = TexturePacks.getColor( 'ui_inventory_description' )

    self.stats = nil
    self.description = nil
end

-- ------------------------------------------------
-- Private Methods
-- ------------------------------------------------

local function addHeader( self, text, item )
    text:add({ self.nameColor, Translator.getText( item:getID() )}, 0, 0 )
end

local function addTypeInformation( self, text, item, tw, th )
    text:add({ self.typeColor, 'Type:' },             COLUMN_1 * tw, 2 * th )
    text:add({ self.valueColor, item:getItemType() }, COLUMN_2 * tw, 2 * th )

    -- Add subtype (if the item has one).
    if item:getItemType() == ITEM_TYPES.WEAPON then
        text:add({ self.typeColor, 'Weapon:' },          COLUMN_3 * tw, 2 * th )
        text:add({ self.valueColor, item:getSubType() }, COLUMN_4 * tw, 2 * th )
    end
end

local function addWeightInformation( self, text, item, tw, th )
    local wgt = string.format( '%.1f', item:getWeight() )
    text:add({ self.typeColor, 'WGT:' }, COLUMN_1 * tw, 3 * th )
    text:add({ self.valueColor, wgt },   COLUMN_2 * tw, 3 * th )

    local vol = string.format( '%.1f', item:getVolume() )
    text:add({ self.typeColor, 'VOL:' }, COLUMN_3 * tw, 3 * th )
    text:add({ self.valueColor, vol },   COLUMN_4 * tw, 3 * th )
end

local function addContainerInformation( self, text, item, tw, th )
    if item:getItemType() == ITEM_TYPES.CONTAINER then
        local volumeLimit = item:getCarryCapacity()
        text:add({ self.typeColor, 'Capacity:' }, COLUMN_1 * tw, 4 * th )
        text:add({ self.valueColor, volumeLimit }, COLUMN_2 * tw, 4 * th )
    end
end

local function addWeaponInformation( self, text, item, tw, th )
    if item:getItemType() ~= ITEM_TYPES.WEAPON then
        return
    end

    if item:getSubType() == WEAPON_TYPES.RANGED then
        local ammo = 'foo'
        text:add({ self.typeColor, 'Ammo:' }, COLUMN_1 * tw, 4 * th )
        text:add({ self.valueColor, ammo },    COLUMN_2 * tw, 4 * th )
    end

    text:add({ self.typeColor, 'MODE' }, WEAPON_COLUMN_MODE * tw, 6 * th )
    text:add({ self.typeColor, 'AP' }, WEAPON_COLUMN_AP * tw, 6 * th )
    text:add({ self.typeColor, 'ACC' }, WEAPON_COLUMN_ACC * tw, 6 * th )
    text:add({ self.typeColor, 'DMG' }, WEAPON_COLUMN_DMG * tw, 6 * th )
    for i, mode in ipairs( item:getModes() ) do
        text:add({ self.valueColor, mode.name }, WEAPON_COLUMN_MODE * tw, (6+i) * th )
        text:add({ self.valueColor, mode.cost }, WEAPON_COLUMN_AP * tw, (6+i) * th )
        text:add({ self.valueColor, mode.accuracy }, WEAPON_COLUMN_ACC * tw, (6+i) * th )
        text:add({ self.valueColor, string.format( '%dx%d', mode.attacks, item:getDamage() )}, WEAPON_COLUMN_DMG * tw, (6+i) * th )
    end
end

local function addDescriptionHeader( self, text, tw, th )
    text:add({ self.typeColor, 'Description:' }, COLUMN_1 * tw, (VERTICAL_DESCRIPTION_OFFSET-1) * th )
end

local function assembleText( self, item )
    local text = love.graphics.newText( TexturePacks.getFont():get() )
    local tw, th = TexturePacks.getGlyphDimensions()

    -- Header.
    addHeader( self, text, item, tw, th )

    -- Add type.
    addTypeInformation( self, text, item, tw, th )

    -- Add weight and volume information.
    addWeightInformation( self, text, item, tw, th )

    -- Add container information.
    addContainerInformation( self, text, item, tw, th )

    -- Add weapon information.
    addWeaponInformation( self, text, item, tw, th )

    -- Add description header.
    addDescriptionHeader( self, text, tw, th )

    return text
end

local function addDescriptionArea( self, item )
    local tw, _ = TexturePacks.getTileDimensions()
    local descriptionText = love.graphics.newText( TexturePacks.getFont():get() )
    descriptionText:setf({ self.descColor, Translator.getText( item:getDescriptionID() )}, (self.w - 1) * tw, 'left' )

    self.description = UIScrollArea( self.ax, self.ay, 0, VERTICAL_DESCRIPTION_OFFSET, self.w, self.h-VERTICAL_DESCRIPTION_OFFSET, descriptionText, descriptionText:getHeight() )
    self:addChild( self.description )
end

-- ------------------------------------------------
-- Public Methods
-- ------------------------------------------------

function UIItemStats:draw()
    if not self.stats then
        return
    end

    local tw, th = TexturePacks.getTileDimensions()

    love.graphics.draw( self.stats, self.ax * tw, self.ay * th )
    self.description:draw()
end

function UIItemStats:setItem( item )
    if item:isInstanceOf( ItemStack ) then
        item = item:getItem()
    end

    self.stats = assembleText( self, item )
    addDescriptionArea( self, item )
end

function UIItemStats:command( cmd, ... )
    if not self:isMouseOver() or not self.description then
        return
    end

    if cmd == 'up' then
        self.description:scroll( -1 )
    elseif cmd == 'down' then
        self.description:scroll( 1 )
    elseif cmd == 'activate' then
        self.description:command( cmd )
    elseif cmd == 'scroll' then
        self.description:scroll( ... )
    end
end

return UIItemStats
