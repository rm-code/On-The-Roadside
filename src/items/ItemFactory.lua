local RangedWeapon = require( 'src.items.weapons.RangedWeapon' );
local MeleeWeapon = require( 'src.items.weapons.MeleeWeapon' );
local Grenade = require( 'src.items.weapons.Grenade' );
local Magazine = require( 'src.items.weapons.Magazine' );
local Rocket = require( 'src.items.weapons.Rocket' );
local ShotgunShell = require( 'src.items.weapons.ShotgunShell' );
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
            local template = love.filesystem.load( dir .. file )();
            local itemType = template.itemType;

            assert( checkItemType( itemType ), string.format( 'Invalid item type %s!', itemType ));

            items[itemType] = items[itemType] or {};
            table.insert( items[itemType], template );

            print( string.format( '  %d. %s', i, template.name ));
        end
    end
end

---
-- Searches the template table for the template for the given item.
-- @param name      (string) The item name to search for.
-- @param templates (table)  The template table to look through.
-- @return          (table)  The template for the given item.
--
local function searchTemplate( name, templates )
    for _, template in ipairs( templates ) do
        if template.name == name then
            return template;
        end
    end
end

---
-- Creates a specific weapon item.
-- @param name (string) The name of the item to create.
-- @return     (Weapon) The new weapon object.
--
local function createWeapon( name )
    local template = searchTemplate( name, items.Weapon );

    if template.weaponType == 'Melee' then
        return MeleeWeapon.new( template );
    elseif template.weaponType == 'Grenade' then
        return Grenade.new( template );
    else
        return RangedWeapon.new( template );
    end
end

---
-- Creates a specific magazine item.
-- @param name (string)   The name of the item to create.
-- @return     (Magazine) The new magazine object.
--
local function createMagazine( name )
    local template = searchTemplate( name, items.Ammunition );
    if template.ammoType == 'Rocket' then
        return Rocket.new( template.name, template.itemType, template.ammoType, template.blastRadius );
    elseif template.ammoType == 'ShotgunShell' then
        return ShotgunShell.new( template.name, template.itemType, template.ammoType, template.pellets );
    end
    return Magazine.new( template.name, template.itemType, template.ammoType );
end

---
-- Creates a specific headgear item.
-- @param name (string)   The name of the item to create.
-- @return     (Headgear) The new clothing instance.
--
local function createHeadgear( name )
    local template = searchTemplate( name, items.Headgear );
    return Headgear.new( template.name, template.itemType, template.armor );
end

---
-- Creates a specific gloves item.
-- @param name (string) The name of the item to create.
-- @return     (Gloves) The new clothing instance.
--
local function createGloves( name )
    local template = searchTemplate( name, items.Gloves );
    return Gloves.new( template.name, template.itemType, template.armor );
end

---
-- Creates a specific jacket item.
-- @param name (string) The name of the item to create.
-- @return     (Jacket) The new clothing instance.
--
local function createJacket( name )
    local template = searchTemplate( name, items.Jacket );
    return Jacket.new( template.name, template.itemType, template.armor );
end

---
-- Creates a specific shirt item.
-- @param name (string) The name of the item to create.
-- @return     (Shirt)  The new clothing instance.
--
local function createShirt( name )
    local template = searchTemplate( name, items.Shirt );
    return Shirt.new( template.name, template.itemType, template.armor );
end

---
-- Creates a specific Trousers item.
-- @param name (string)   The name of the item to create.
-- @return     (Trousers) The new clothing instance.
--
local function createTrousers( name )
    local template = searchTemplate( name, items.Trousers );
    return Trousers.new( template.name, template.itemType, template.armor );
end

---
-- Creates a specific footwear item.
-- @param name (string)   The name of the item to create.
-- @return     (Footwear) The new clothing instance.
--
local function createFootwear( name )
    local template = searchTemplate( name, items.Footwear );
    return Footwear.new( template.name, template.itemType, template.armor );
end

---
-- Creates a specific bag item.
-- @param name (string) The name of the item to create.
-- @return     (Bag)    The new bag instance.
--
local function createBag( name )
    local template = searchTemplate( name, items.Bag );
    return Bag.new( template );
end

-- ------------------------------------------------
-- Public Functions
-- ------------------------------------------------

---
-- Loads all templates.
--
function ItemFactory.loadTemplates()
    print( "Load Footwear Templates:" )
    load( TEMPLATES_DIRECTORY_FOOTWEAR );

    print( "Load Glove Templates:" )
    load( TEMPLATES_DIRECTORY_GLOVES );

    print( "Load Headgear Templates:" )
    load( TEMPLATES_DIRECTORY_HEADGEAR );

    print( "Load Jacket Templates:" )
    load( TEMPLATES_DIRECTORY_JACKETS );

    print( "Load Shirt Templates:" )
    load( TEMPLATES_DIRECTORY_SHIRTS );

    print( "Load Trouser Templates:" )
    load( TEMPLATES_DIRECTORY_TROUSERS );

    print( "Load Weapon Templates:" )
    load( TEMPLATES_DIRECTORY_WEAPONS );

    print( "Load Bag Templates:" )
    load( TEMPLATES_DIRECTORY_BAGS );

    print( "Load Ammunition Templates:" );
    load( TEMPLATES_DIRECTORY_AMMO );
end

---
-- Creates a specific item specified by type and name.
-- @param type (string) The type of the item to create.
-- @param name (string) The name of the item to create.
-- @return     (Item)   The new item.
--
function ItemFactory.createItem( type, name )
    if type == ITEM_TYPES.WEAPON then
        return createWeapon( name );
    elseif type == ITEM_TYPES.BAG then
        return createBag( name );
    elseif type == ITEM_TYPES.AMMO then
        return createMagazine( name );
    elseif type == ITEM_TYPES.HEADGEAR then
        return createHeadgear( name );
    elseif type == ITEM_TYPES.GLOVES then
        return createGloves( name );
    elseif type == ITEM_TYPES.JACKET then
        return createJacket( name );
    elseif type == ITEM_TYPES.SHIRT then
        return createShirt( name );
    elseif type == ITEM_TYPES.TROUSERS then
        return createTrousers( name );
    elseif type == ITEM_TYPES.FOOTWEAR then
        return createFootwear( name );
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
        return createWeapon( template.name );
    elseif type == ITEM_TYPES.BAG then
        local rnd = love.math.random( 1, #items.Bag );
        local template = items.Bag[rnd];
        return createBag( template.name );
    elseif type == ITEM_TYPES.HEADGEAR then
        local rnd = love.math.random( 1, #items.Headgear );
        local template = items.Headgear[rnd];
        return createHeadgear( template.name );
    elseif type == ITEM_TYPES.GLOVES then
        local rnd = love.math.random( 1, #items.Gloves );
        local template = items.Gloves[rnd];
        return createGloves( template.name );
    elseif type == ITEM_TYPES.JACKET then
        local rnd = love.math.random( 1, #items.Jacket );
        local template = items.Jacket[rnd];
        return createJacket( template.name );
    elseif type == ITEM_TYPES.SHIRT then
        local rnd = love.math.random( 1, #items.Shirt );
        local template = items.Shirt[rnd];
        return createShirt( template.name );
    elseif type == ITEM_TYPES.TROUSERS then
        local rnd = love.math.random( 1, #items.Trousers );
        local template = items.Trousers[rnd];
        return createTrousers( template.name );
    elseif type == ITEM_TYPES.FOOTWEAR then
        local rnd = love.math.random( 1, #items.Footwear );
        local template = items.Footwear[rnd];
        return createFootwear( template.name );
    end
end

return ItemFactory;
