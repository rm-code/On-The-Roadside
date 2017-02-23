local Log = require( 'src.util.Log' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ItemFactory = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local ITEM_TYPES = require('src.constants.ItemTypes');
local WEAPON_TYPES = require( 'src.constants.WeaponTypes' );

local TEMPLATES_MELEE      = 'res.data.items.weapons.Melee';
local TEMPLATES_RANGED     = 'res.data.items.weapons.Ranged';
local TEMPLATES_THROWN     = 'res.data.items.weapons.Thrown';
local TEMPLATES_ARMOR      = 'res.data.items.Armor';
local TEMPLATES_CONTAINERS = 'res.data.items.Containers';
local TEMPLATES_AMMO       = 'res.data.items.Ammunition';
local TEMPLATES_MISC       = 'res.data.items.Miscellaneous';

local ITEM_CLASSES = {
    [ITEM_TYPES.ARMOR]    = require( 'src.items.Armor' ),
    [ITEM_TYPES.BAG]      = require( 'src.items.Bag' ),
    [ITEM_TYPES.MISC]     = require( 'src.items.Item' ),
    [ITEM_TYPES.AMMO]     = require( 'src.items.weapons.Ammunition' ),
    [WEAPON_TYPES.MELEE]  = require( 'src.items.weapons.MeleeWeapon' ),
    [WEAPON_TYPES.RANGED] = require( 'src.items.weapons.RangedWeapon' ),
    [WEAPON_TYPES.THROWN] = require( 'src.items.weapons.ThrownWeapon' )
}

-- ------------------------------------------------
-- Private Variables
-- ------------------------------------------------

local items = {};
local counter = 0;

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Loads item templates from the specified directory and stores them in the items table.
-- @param src (string) The module to load the templates from.
--
local function load( src )
    local module = require( src );

    for _, template in ipairs( module ) do
        items[template.id] = template;
        counter = counter + 1;
        Log.debug( string.format( '  %3d. %s', counter, template.id ));
    end
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Loads all templates.
--
function ItemFactory.loadTemplates()
    Log.debug( "Load Item Templates:" );
    load( TEMPLATES_ARMOR );
    load( TEMPLATES_MELEE );
    load( TEMPLATES_RANGED );
    load( TEMPLATES_THROWN );
    load( TEMPLATES_CONTAINERS );
    load( TEMPLATES_AMMO );
    load( TEMPLATES_MISC );
end

---
-- Creates a specific item specified by type and id.
-- @param id   (string) The id of the item to create.
-- @return     (Item)   The new item.
--
function ItemFactory.createItem( id )
    local template = items[id];
    Log.debug( template.itemType .. ', ' .. tostring(template.subType), 'ItemFactory' );
    if template.itemType == ITEM_TYPES.WEAPON then
        return ITEM_CLASSES[template.subType].new( template );
    end
    return ITEM_CLASSES[template.itemType].new( template );
end

---
-- Creates a random item of a certain type.
-- @param type    (string) The type of the item to create.
-- @param subType (string) The sub type of the item to create.
-- @return        (Item)   The new item.
--
function ItemFactory.createRandomItem( tags, type, subType )
    -- Compile a list of items from this type.
    local list = {};
    for id, template in pairs( items ) do
        if template.itemType == type then
            if not subType or template.subType == subType then

                if tags == 'all' then
                    list[#list + 1] = id;
                else
                    -- Check if the creature's tags allow items of this type.
                    local whitelisted, blacklisted;
                    for _, itemTag in ipairs( template.tags ) do
                        whitelisted, blacklisted = false, false;
                        for _, creatureTag in ipairs( tags.whitelist ) do
                            if itemTag == creatureTag then
                                whitelisted = true;
                            end
                        end
                        for _, creatureTag in ipairs( tags.blacklist ) do
                            if itemTag == creatureTag then
                                blacklisted = true;
                            end
                        end
                        if not whitelisted or blacklisted then
                            break;
                        end
                    end

                    if whitelisted and not blacklisted then
                        list[#list + 1] = id;
                    end
                end
            end
        end
    end

    -- Select a random item from the list.
    local id = list[love.math.random( 1, #list )];
    return ItemFactory.createItem( id );
end

return ItemFactory;
