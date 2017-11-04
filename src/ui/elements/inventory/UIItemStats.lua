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

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local UIItemStats = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local ITEM_TYPES = require('src.constants.ITEM_TYPES')
local WEAPON_TYPES = require( 'src.constants.WEAPON_TYPES' )

local COLUMN_1 = 0
local COLUMN_2 = 10
local COLUMN_3 = 22
local COLUMN_4 = 30

local WEAPON_COLUMN_MODE    =  0
local WEAPON_COLUMN_AP      = 20
local WEAPON_COLUMN_ACC     = 25
local WEAPON_COLUMN_ATTACKS = 30

local VERTICAL_DESCRIPTION_OFFSET = 12

-- ------------------------------------------------
-- Constructor
-- ------------------------------------------------

function UIItemStats.new( px, py, x, y, w, h )
    local self = UIElement.new( px, py, x, y, w, h ):addInstance( 'UIItemStats' )

    -- ------------------------------------------------
    -- Private Attributes
    -- ------------------------------------------------

    local nameColor  = TexturePacks.getColor( 'ui_inventory_stats_name' )
    local typeColor  = TexturePacks.getColor( 'ui_inventory_stats_type' )
    local valueColor = TexturePacks.getColor( 'ui_inventory_stats_value' )
    local descColor  = TexturePacks.getColor( 'ui_inventory_description' )

    local stats
    local description

    -- ------------------------------------------------
    -- Private Methods
    -- ------------------------------------------------

    local function addHeader( ntext, item )
        ntext:add({ nameColor, Translator.getText( item:getID() )}, 0, 0 )
    end

    local function addTypeInformation( ntext, item, tw, th )
        ntext:add({ typeColor, 'Type:' },             COLUMN_1 * tw, 2 * th )
        ntext:add({ valueColor, item:getItemType() }, COLUMN_2 * tw, 2 * th )

        -- Add subtype (if the item has one).
        if item:getItemType() == ITEM_TYPES.WEAPON then
            ntext:add({ typeColor, 'Weapon:' },          COLUMN_3 * tw, 2 * th )
            ntext:add({ valueColor, item:getSubType() }, COLUMN_4 * tw, 2 * th )
        end
    end

    local function addWeightInformation( ntext, item, tw, th )
        local wgt = string.format( '%.1f', item:getWeight() )
        ntext:add({ typeColor, 'WGT:' }, COLUMN_1 * tw, 3 * th )
        ntext:add({ valueColor, wgt },   COLUMN_2 * tw, 3 * th )

        local vol = string.format( '%.1f', item:getVolume() )
        ntext:add({ typeColor, 'VOL:' }, COLUMN_3 * tw, 3 * th )
        ntext:add({ valueColor, vol },   COLUMN_4 * tw, 3 * th )
    end

    local function addContainerInformation( ntext, item, tw, th )
        if item:getItemType() == ITEM_TYPES.CONTAINER then
            local volumeLimit = item:getCarryCapacity()
            ntext:add({ typeColor, 'Capacity:' }, COLUMN_1 * tw, 4 * th )
            ntext:add({ valueColor, volumeLimit }, COLUMN_2 * tw, 4 * th )
        end
    end

    local function addWeaponInformation( ntext, item, tw, th )
        if item:getItemType() ~= ITEM_TYPES.WEAPON then
            return
        end

        if item:getSubType() == WEAPON_TYPES.RANGED then
            local ammo = item:getMagazine():getCaliber()
            ntext:add({ typeColor, 'Ammo:' }, COLUMN_1 * tw, 4 * th )
            ntext:add({ valueColor, ammo },    COLUMN_2 * tw, 4 * th )
            love.graphics.print( 'Ammo: ' .. item:getMagazine():getCaliber(), (x + w * 0.5) * tw, (y + 2) * th )
        end

        ntext:add({ typeColor, 'MODE' },    WEAPON_COLUMN_MODE    * tw, 6 * th )
        ntext:add({ typeColor, 'AP' },      WEAPON_COLUMN_AP      * tw, 6 * th )
        ntext:add({ typeColor, 'ACC' },     WEAPON_COLUMN_ACC     * tw, 6 * th )
        ntext:add({ typeColor, 'ATTACKS' }, WEAPON_COLUMN_ATTACKS * tw, 6 * th )
        for i, mode in ipairs( item:getModes() ) do
            ntext:add({ valueColor, mode.name },     WEAPON_COLUMN_MODE    * tw, (6+i) * th )
            ntext:add({ valueColor, mode.cost },     WEAPON_COLUMN_AP      * tw, (6+i) * th )
            ntext:add({ valueColor, mode.accuracy }, WEAPON_COLUMN_ACC     * tw, (6+i) * th )
            ntext:add({ valueColor, mode.attacks  }, WEAPON_COLUMN_ATTACKS * tw, (6+i) * th )
        end
    end

    local function addDescriptionHeader( ntext, tw, th )
        ntext:add({ typeColor, 'Description:' }, COLUMN_1 * tw, (VERTICAL_DESCRIPTION_OFFSET-1) * th )
    end

    local function assembleText( item )
        local ntext = love.graphics.newText( TexturePacks.getFont():get() )
        local tw, th = TexturePacks.getGlyphDimensions()

        -- Header.
        addHeader( ntext, item, tw, th )

        -- Add type.
        addTypeInformation( ntext, item, tw, th )

        -- Add weight and volume information.
        addWeightInformation( ntext, item, tw, th )

        -- Add container information.
        addContainerInformation( ntext, item, tw, th )

        -- Add weapon information.
        addWeaponInformation( ntext, item, tw, th )

        -- Add description header.
        addDescriptionHeader( ntext, tw, th )

        return ntext
    end

    local function addDescriptionArea( item )
        description = UIScrollArea.new( self.ax, self.ay, 0, VERTICAL_DESCRIPTION_OFFSET, self.w, self.h-VERTICAL_DESCRIPTION_OFFSET )
        description:init({ descColor, Translator.getText( item:getDescriptionID() )})
        self:addChild( description )
    end

    -- ------------------------------------------------
    -- Public Methods
    -- ------------------------------------------------

    function self:draw()
        if not stats then
            return
        end

        local tw, th = TexturePacks.getTileDimensions()

        love.graphics.draw( stats, self.ax * tw, self.ay * th )
        description:draw()
    end

    function self:setItem( item )
        stats = assembleText( item )
        addDescriptionArea( item )
    end

    function self:keypressed( k )
        if not self:isMouseOver() or not description then
            return
        end

        if k == 'up' then
            description:scroll( -1 )
        elseif k == 'down' then
            description:scroll( 1 )
        end
    end

    function self:mousepressed( mx, my )
        if not self:isMouseOver() or not description then
            return
        end

        if description:isMouseOver() then
            description:mousepressed( mx, my )
        end
    end

    function self:wheelmoved( _, dy )
        if not self:isMouseOver() or not description then
            return
        end

        description:scroll( dy )
    end

    return self
end

return UIItemStats
