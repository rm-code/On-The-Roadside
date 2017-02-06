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

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ItemFactory = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local ITEM_TYPES = require('src.constants.ItemTypes');

local TEMPLATES_DIRECTORY_FOOTWEAR = 'res/data/items/clothing/footwear/';
local TEMPLATES_DIRECTORY_GLOVES   = 'res/data/items/clothing/gloves/';
local TEMPLATES_DIRECTORY_HEADGEAR = 'res/data/items/clothing/headgear/';
local TEMPLATES_DIRECTORY_JACKETS  = 'res/data/items/clothing/jackets/';
local TEMPLATES_DIRECTORY_SHIRTS   = 'res/data/items/clothing/shirts/';
local TEMPLATES_DIRECTORY_TROUSERS = 'res/data/items/clothing/trousers/';
local TEMPLATES_DIRECTORY_WEAPONS  = 'res/data/items/weapons/';
local TEMPLATES_DIRECTORY_BAGS     = 'res/data/items/bags/';
local TEMPLATES_DIRECTORY_AMMO     = 'res/data/items/ammunition/';

-- ------------------------------------------------
-- Private Variables
-- ------------------------------------------------

local items = {};

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Checks if the item type is valid.
-- @param type (string)  The type to check.
-- @return     (boolean) True if the item type is valid.
--
local function checkItemType( type )
    if type == ITEM_TYPES.WEAPON then
        return true;
    elseif type == ITEM_TYPES.HEADGEAR then
        return true;
    elseif type == ITEM_TYPES.GLOVES then
        return true;
    elseif type == ITEM_TYPES.JACKET then
        return true;
    elseif type == ITEM_TYPES.SHIRT then
        return true;
    elseif type == ITEM_TYPES.TROUSERS then
        return true;
    elseif type == ITEM_TYPES.FOOTWEAR then
        return true;
    elseif type == ITEM_TYPES.BAG then
        return true;
    elseif type == ITEM_TYPES.AMMO then
        return true;
    end
    return false
end

---
-- Loads item templates from the specified directory and stores them in the
-- items table.
-- @param dir (string) The directory url to load the templates from.
--
local function load( dir )
    local files = love.filesystem.getDirectoryItems( dir );
    for i, file in ipairs( files ) do
        if love.filesystem.isFile( dir .. file ) then
            local status, loaded = pcall( love.filesystem.load, dir .. file );
            if not status then
                Log.warn( 'Can not load ' .. dir .. file );
            else
                local template = loaded();
                local itemType = template.itemType;

                assert( checkItemType( itemType ), string.format( 'Invalid item type %s!', itemType ));

                items[itemType] = items[itemType] or {};
                table.insert( items[itemType], template );

                Log.info( string.format( '  %d. %s', i, template.id ));
            end
        end
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

    if template.weaponType == 'Melee' then
        return MeleeWeapon.new( template );
    elseif template.weaponType == 'Thrown' then
        return ThrownWeapon.new( template );
    else
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

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Loads all templates.
--
function ItemFactory.loadTemplates()
    Log.info( "Load Footwear Templates:" )
    load( TEMPLATES_DIRECTORY_FOOTWEAR );

    Log.info( "Load Glove Templates:" )
    load( TEMPLATES_DIRECTORY_GLOVES );

    Log.info( "Load Headgear Templates:" )
    load( TEMPLATES_DIRECTORY_HEADGEAR );

    Log.info( "Load Jacket Templates:" )
    load( TEMPLATES_DIRECTORY_JACKETS );

    Log.info( "Load Shirt Templates:" )
    load( TEMPLATES_DIRECTORY_SHIRTS );

    Log.info( "Load Trouser Templates:" )
    load( TEMPLATES_DIRECTORY_TROUSERS );

    Log.info( "Load Weapon Templates:" )
    load( TEMPLATES_DIRECTORY_WEAPONS );

    Log.info( "Load Bag Templates:" )
    load( TEMPLATES_DIRECTORY_BAGS );

    Log.info( "Load Ammunition Templates:" );
    load( TEMPLATES_DIRECTORY_AMMO );
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
    end
end

return ItemFactory;
