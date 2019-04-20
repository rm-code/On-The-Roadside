---
-- @module ItemFactory
--

-- ------------------------------------------------
-- Required Modules
-- ------------------------------------------------

local Log = require( 'src.util.Log' )

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ItemFactory = {}

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local ITEM_TYPES = require('src.constants.ITEM_TYPES')
local WEAPON_TYPES = require( 'src.constants.WEAPON_TYPES' )

local TEMPLATES_MELEE      = 'res.data.items.weapons.Melee'
local TEMPLATES_RANGED     = 'res.data.items.weapons.Ranged'
local TEMPLATES_THROWN     = 'res.data.items.weapons.Thrown'
local TEMPLATES_ARMOR      = 'res.data.items.Armor'
local TEMPLATES_CONTAINERS = 'res.data.items.Containers'
local TEMPLATES_MISC       = 'res.data.items.Miscellaneous'

local ITEM_CLASSES = {
    [ITEM_TYPES.ARMOR    ] = require( 'src.items.Armor'                ),
    [ITEM_TYPES.CONTAINER] = require( 'src.items.Container'            ),
    [ITEM_TYPES.MISC     ] = require( 'src.items.Item'                 ),
    [WEAPON_TYPES.MELEE  ] = require( 'src.items.weapons.MeleeWeapon'  ),
    [WEAPON_TYPES.RANGED ] = require( 'src.items.weapons.RangedWeapon' ),
    [WEAPON_TYPES.THROWN ] = require( 'src.items.weapons.ThrownWeapon' )
}

-- ------------------------------------------------
-- Private Variables
-- ------------------------------------------------

local items = {}
local counter = 0

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Loads item templates from the specified directory and stores them in the items table.
-- @tparam string src The module to load the templates from.
--
local function load( src )
    local module = require( src )

    for _, template in ipairs( module ) do
        items[template.id] = template
        counter = counter + 1
        Log.debug( string.format( '  %3d. %s', counter, template.id ))
    end
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Loads all templates.
--
function ItemFactory.loadTemplates()
    Log.debug( "Load Item Templates:" )
    load( TEMPLATES_ARMOR )
    load( TEMPLATES_MELEE )
    load( TEMPLATES_RANGED )
    load( TEMPLATES_THROWN )
    load( TEMPLATES_CONTAINERS )
    load( TEMPLATES_MISC )
end

---
-- Creates a specific item specified by type and id.
-- @tparam  string id The id of the item to create.
-- @treturn Item      The new item.
--
function ItemFactory.createItem( id )
    local template = items[id]
    Log.debug( template.itemType .. ', ' .. tostring(template.subType), 'ItemFactory' )
    if template.itemType == ITEM_TYPES.WEAPON then
        return ITEM_CLASSES[template.subType]( template )
    end
    return ITEM_CLASSES[template.itemType]( template )
end

---
-- Loads an item that was loaded from a savegame.
-- @tparam table savedItem A table containing saved information about an item.
-- @treturn Item           The loaded item.
--
function ItemFactory.loadItem( savedItem )
    local item = ItemFactory.createItem( savedItem.id )

    -- Special case for weapons that sets the weapon's attack mode and fills
    -- its magazine with ammunition if it is reloadable.
    if item:getItemType() == ITEM_TYPES.WEAPON then
        item:setAttackMode( savedItem.modeIndex )
        if item:isReloadable() then
            item:setCurrentCapacity( savedItem.currentCapacity )
        end
    end

    return item
end

---
-- Creates a random item of a certain type.
-- @tparam  string type    The type of the item to create.
-- @tparam  string subType The sub type of the item to create.
-- @treturn Item           The new item.
--
function ItemFactory.createRandomItem( tags, type, subType )
    -- Compile a list of items from this type.
    local list = {}
    for id, template in pairs( items ) do
        if template.itemType == type then
            if not subType or template.subType == subType then
                -- Check if the creature's tags allow items of this type.
                local whitelisted, blacklisted
                for _, itemTag in ipairs( template.tags ) do
                    whitelisted, blacklisted = false, false
                    for _, creatureTag in ipairs( tags.whitelist ) do
                        if itemTag == creatureTag then
                            whitelisted = true
                        end
                    end
                    for _, creatureTag in ipairs( tags.blacklist ) do
                        if itemTag == creatureTag then
                            blacklisted = true
                        end
                    end
                    if not whitelisted or blacklisted then
                        break
                    end
                end

                if whitelisted and not blacklisted then
                    list[#list + 1] = id
                end
            end
        end
    end

    -- Select a random item from the list.
    local id = list[love.math.random( 1, #list )]
    return ItemFactory.createItem( id )
end

return ItemFactory
