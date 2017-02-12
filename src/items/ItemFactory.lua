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

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Loads item templates from the specified directory and stores them in the
-- items table.
-- @param src (string) The module to load the templates from.
--
local function load( src )
    local module = require( src );
    for _, template in ipairs( module ) do
        local itemType = template.itemType;
        items[itemType] = items[itemType] or {};
        table.insert( items[itemType], template );
        Log.debug( string.format( '  %s', template.id ));
    end
end

---
-- Searches the template table for the template for the given item.
-- @param id        (string) The item id to search for.
-- @param templates (table)  The template table to look through.
-- @return          (table)  The template for the given item.
--
local function searchTemplate( id, templates )
    for _, template in ipairs( templates ) do
        if template.id == id then
            return template;
        end
    end
end

---
-- Creates a specific weapon item.
-- @param id (string) The id of the item to create.
-- @return   (Weapon) The new weapon object.
--
local function createWeapon( id )
    local template = searchTemplate( id, items.Weapon );

    if template.weaponType == WEAPON_TYPES.MELEE then
        return MeleeWeapon.new( template );
    elseif template.weaponType == WEAPON_TYPES.THROWN then
        return ThrownWeapon.new( template );
    elseif template.weaponType == WEAPON_TYPES.RANGED then
        return RangedWeapon.new( template );
    end
end

---
-- Creates a specific magazine item.
-- @param id (string)   The id of the item to create.
-- @return   (Magazine) The new magazine object.
--
local function createMagazine( id )
    local template = searchTemplate( id, items.Ammunition );
    return Ammunition.new( template );
end

---
-- Creates a specific headgear item.
-- @param id (string)   The id of the item to create.
-- @return   (Headgear) The new clothing instance.
--
local function createHeadgear( id )
    local template = searchTemplate( id, items.Headgear );
    return Headgear.new( template );
end

---
-- Creates a specific gloves item.
-- @param id (string) The id of the item to create.
-- @return   (Gloves) The new clothing instance.
--
local function createGloves( id )
    local template = searchTemplate( id, items.Gloves );
    return Gloves.new( template );
end

---
-- Creates a specific jacket item.
-- @param id (string) The id of the item to create.
-- @return   (Jacket) The new clothing instance.
--
local function createJacket( id )
    local template = searchTemplate( id, items.Jacket );
    return Jacket.new( template );
end

---
-- Creates a specific shirt item.
-- @param id (string) The id of the item to create.
-- @return   (Shirt)  The new clothing instance.
--
local function createShirt( id )
    local template = searchTemplate( id, items.Shirt );
    return Shirt.new( template );
end

---
-- Creates a specific Trousers item.
-- @param id (string)   The id of the item to create.
-- @return   (Trousers) The new clothing instance.
--
local function createTrousers( id )
    local template = searchTemplate( id, items.Trousers );
    return Trousers.new( template );
end

---
-- Creates a specific footwear item.
-- @param id (string)   The id of the item to create.
-- @return   (Footwear) The new clothing instance.
--
local function createFootwear( id )
    local template = searchTemplate( id, items.Footwear );
    return Footwear.new( template );
end

---
-- Creates a specific bag item.
-- @param id (string) The id of the item to create.
-- @return   (Bag)    The new bag instance.
--
local function createBag( id )
    local template = searchTemplate( id, items.Bag );
    return Bag.new( template );
end

---
-- Creates a miscellaneous item.
-- @param id (string) The id of the item to create.
-- @return   (Item)   The new miscellaneous item instance.
--
local function createMiscellaneous( id )
    local template = searchTemplate( id, items.Miscellaneous );
    return Item.new( template );
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Loads all templates.
--
function ItemFactory.loadTemplates()
    Log.debug( "Load Footwear Templates:" )
    load( TEMPLATES_FOOTWEAR );

    Log.debug( "Load Glove Templates:" )
    load( TEMPLATES_GLOVES );

    Log.debug( "Load Headgear Templates:" )
    load( TEMPLATES_HEADGEAR );

    Log.debug( "Load Jacket Templates:" )
    load( TEMPLATES_JACKETS );

    Log.debug( "Load Shirt Templates:" )
    load( TEMPLATES_SHIRTS );

    Log.debug( "Load Trouser Templates:" )
    load( TEMPLATES_TROUSERS );

    Log.debug( "Load Melee Weapon Templates:" )
    load( TEMPLATES_MELEE );

    Log.debug( "Load Ranged Weapon Templates:" )
    load( TEMPLATES_RANGED );

    Log.debug( "Load Thrown Weapon Templates:" )
    load( TEMPLATES_THROWN );

    Log.debug( "Load Container Templates:" )
    load( TEMPLATES_CONTAINERS );

    Log.debug( "Load Ammunition Templates:" );
    load( TEMPLATES_AMMO );

    Log.debug( "Load Miscellaneous Templates:" );
    load( TEMPLATES_MISC );
end

---
-- Creates a specific item specified by type and id.
-- @param type (string) The type of the item to create.
-- @param id   (string) The id of the item to create.
-- @return     (Item)   The new item.
--
function ItemFactory.createItem( type, id )
    if type == ITEM_TYPES.WEAPON then
        return createWeapon( id );
    elseif type == ITEM_TYPES.BAG then
        return createBag( id );
    elseif type == ITEM_TYPES.AMMO then
        return createMagazine( id );
    elseif type == ITEM_TYPES.HEADGEAR then
        return createHeadgear( id );
    elseif type == ITEM_TYPES.GLOVES then
        return createGloves( id );
    elseif type == ITEM_TYPES.JACKET then
        return createJacket( id );
    elseif type == ITEM_TYPES.SHIRT then
        return createShirt( id );
    elseif type == ITEM_TYPES.TROUSERS then
        return createTrousers( id );
    elseif type == ITEM_TYPES.FOOTWEAR then
        return createFootwear( id );
    elseif type == ITEM_TYPES.MISC then
        return createMiscellaneous( id );
    end
end

---
-- Creates a random item of a certain type.
-- @param type (string) The type of the item to create.
-- @return     (Item)   The new item.
--
function ItemFactory.createRandomItem( type )
    if type == ITEM_TYPES.WEAPON then
        local rnd = love.math.random( 1, #items.Weapon );
        local template = items.Weapon[rnd];
        return createWeapon( template.id );
    elseif type == ITEM_TYPES.AMMO then
        local rnd = love.math.random( 1, #items.Ammunition );
        local template = items.Ammunition[rnd];
        return createMagazine( template.id );
    elseif type == ITEM_TYPES.BAG then
        local rnd = love.math.random( 1, #items.Bag );
        local template = items.Bag[rnd];
        return createBag( template.id );
    elseif type == ITEM_TYPES.HEADGEAR then
        local rnd = love.math.random( 1, #items.Headgear );
        local template = items.Headgear[rnd];
        return createHeadgear( template.id );
    elseif type == ITEM_TYPES.GLOVES then
        local rnd = love.math.random( 1, #items.Gloves );
        local template = items.Gloves[rnd];
        return createGloves( template.id );
    elseif type == ITEM_TYPES.JACKET then
        local rnd = love.math.random( 1, #items.Jacket );
        local template = items.Jacket[rnd];
        return createJacket( template.id );
    elseif type == ITEM_TYPES.SHIRT then
        local rnd = love.math.random( 1, #items.Shirt );
        local template = items.Shirt[rnd];
        return createShirt( template.id );
    elseif type == ITEM_TYPES.TROUSERS then
        local rnd = love.math.random( 1, #items.Trousers );
        local template = items.Trousers[rnd];
        return createTrousers( template.id );
    elseif type == ITEM_TYPES.FOOTWEAR then
        local rnd = love.math.random( 1, #items.Footwear );
        local template = items.Footwear[rnd];
        return createFootwear( template.id );
    elseif type == ITEM_TYPES.MISC then
        local rnd = love.math.random( 1, #items.Miscellaneous );
        local template = items.Miscellaneous[rnd];
        return createMiscellaneous( template.id );
    end
end

return ItemFactory;
