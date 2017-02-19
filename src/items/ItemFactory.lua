local Log = require( 'src.util.Log' );
local RangedWeapon = require( 'src.items.weapons.RangedWeapon' );
local MeleeWeapon = require( 'src.items.weapons.MeleeWeapon' );
local ThrownWeapon = require( 'src.items.weapons.ThrownWeapon' );
local Ammunition = require( 'src.items.weapons.Ammunition' );
local Footwear = require( 'src.items.clothes.Footwear' );
local Gloves = require( 'src.items.clothes.Gloves' );
local Headgear = require( 'src.items.clothes.Headgear' );
local Jacket = require( 'src.items.clothes.Jacket' );
local Shirt = require( 'src.items.clothes.Shirt' );
local Trousers = require( 'src.items.clothes.Trousers' );
local Bag = require( 'src.items.Bag' );
local Item = require( 'src.items.Item' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ItemFactory = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local ITEM_TYPES = require('src.constants.ItemTypes');
local WEAPON_TYPES = require( 'src.constants.WeaponTypes' );

local TEMPLATES_FOOTWEAR   = 'res.data.items.clothing.Footwear';
local TEMPLATES_GLOVES     = 'res.data.items.clothing.Gloves';
local TEMPLATES_HEADGEAR   = 'res.data.items.clothing.Headgear';
local TEMPLATES_JACKETS    = 'res.data.items.clothing.Jackets';
local TEMPLATES_SHIRTS     = 'res.data.items.clothing.Shirts';
local TEMPLATES_TROUSERS   = 'res.data.items.clothing.Trousers';
local TEMPLATES_MELEE      = 'res.data.items.weapons.Melee';
local TEMPLATES_RANGED     = 'res.data.items.weapons.Ranged';
local TEMPLATES_THROWN     = 'res.data.items.weapons.Thrown';
local TEMPLATES_CONTAINERS = 'res.data.items.Containers';
local TEMPLATES_AMMO       = 'res.data.items.Ammunition';
local TEMPLATES_MISC       = 'res.data.items.Miscellaneous';

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
    load( TEMPLATES_FOOTWEAR );
    load( TEMPLATES_GLOVES );
    load( TEMPLATES_HEADGEAR );
    load( TEMPLATES_JACKETS );
    load( TEMPLATES_SHIRTS );
    load( TEMPLATES_TROUSERS );
    load( TEMPLATES_MELEE );
    load( TEMPLATES_RANGED );
    load( TEMPLATES_THROWN );
    load( TEMPLATES_CONTAINERS );
    load( TEMPLATES_AMMO );
    load( TEMPLATES_MISC );
end

---
-- Creates a specific item specified by type and id.
-- @param type (string) The type of the item to create.
-- @param id   (string) The id of the item to create.
-- @return     (Item)   The new item.
--
function ItemFactory.createItem( type, id )
    local template = items[id];
    if type == ITEM_TYPES.WEAPON then
        if template.weaponType == WEAPON_TYPES.MELEE then
            return MeleeWeapon.new( template );
        elseif template.weaponType == WEAPON_TYPES.THROWN then
            return ThrownWeapon.new( template );
        elseif template.weaponType == WEAPON_TYPES.RANGED then
            return RangedWeapon.new( template );
        end
    elseif type == ITEM_TYPES.BAG then
        return Bag.new( template );
    elseif type == ITEM_TYPES.AMMO then
        return Ammunition.new( template );
    elseif type == ITEM_TYPES.HEADGEAR then
        return Headgear.new( template );
    elseif type == ITEM_TYPES.GLOVES then
        return Gloves.new( template );
    elseif type == ITEM_TYPES.JACKET then
        return Jacket.new( template );
    elseif type == ITEM_TYPES.SHIRT then
        return Shirt.new( template );
    elseif type == ITEM_TYPES.TROUSERS then
        return Trousers.new( template );
    elseif type == ITEM_TYPES.FOOTWEAR then
        return Footwear.new( template );
    elseif type == ITEM_TYPES.MISC then
        return Item.new( template );
    end
end

---
-- Creates a random item of a certain type.
-- @param type (string) The type of the item to create.
-- @return     (Item)   The new item.
--
function ItemFactory.createRandomItem( type )
    -- Compile a list of items from this type.
    local list = {};
    for id, template in pairs( items ) do
        if template.itemType == type then
            list[#list + 1] = id;
        end
    end

    -- Select a random item from the list.
    local id = list[love.math.random( 1, #list )];
    return ItemFactory.createItem( type, id );
end

return ItemFactory;
