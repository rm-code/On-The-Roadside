local Weapon = require( 'src.items.weapons.Weapon' );
local Magazine = require( 'src.items.weapons.Magazine' );
local Rocket = require( 'src.items.weapons.Rocket' );
local Clothing = require( 'src.items.Clothing' );
local Bag = require( 'src.items.Bag' );

-- ------------------------------------------------
-- Module
-- ------------------------------------------------

local ItemFactory = {};

-- ------------------------------------------------
-- Constants
-- ------------------------------------------------

local ITEM_TYPES = require('src.constants.ItemTypes');
local CLOTHING_SLOTS = require('src.constants.ClothingSlots');

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
    elseif type == ITEM_TYPES.CLOTHING then
        return true;
    elseif type == ITEM_TYPES.BAG then
        return true;
    elseif type == ITEM_TYPES.AMMO then
        return true;
    end
    return false
end

---
-- Checks if the clothing type is valid.
-- @param type (string)  The clothing type to check.
-- @return     (boolean) True if the clothing type is valid.
--
local function checkClothingType( type )
    if type == CLOTHING_SLOTS.HEADGEAR then
        return true;
    elseif type == CLOTHING_SLOTS.GLOVES then
        return true;
    elseif type == CLOTHING_SLOTS.JACKET then
        return true;
    elseif type == CLOTHING_SLOTS.SHIRT then
        return true;
    elseif type == CLOTHING_SLOTS.TROUSERS then
        return true;
    elseif type == CLOTHING_SLOTS.FOOTWEAR then
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

            if itemType == ITEM_TYPES.CLOTHING then
                local clothingType = template.clothingType;
                assert( checkClothingType( clothingType ), string.format( 'Invalid clothing type %s!', clothingType ));

                items[itemType][clothingType] = items[itemType][clothingType] or {};
                table.insert( items[itemType][clothingType], template );
            else
                table.insert( items[itemType], template );
            end

            print( string.format( '  %d. %s', i, template.name ));
        end
    end
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
-- Creates a new random weapon.
-- @return (Weapon) The new weapon instance.
--
function ItemFactory.createWeapon()
    local rnd = love.math.random( 1, #items.Weapon );
    local template = items.Weapon[rnd];
    return Weapon.new( template );
end

---
-- Creates a new magazine for the given caliber.
-- @param caliber  (string)   The specific caliber to create.
-- @param capacity (number)   The magazine's total capacity.
-- @return         (Magazine) The new magazine instance.
--
function ItemFactory.createMagazine( caliber, capacity )
    local ammo;
    for _, template in ipairs( items.Ammunition ) do
        if template.caliber == caliber then
            ammo = template;
            break;
        end
    end
    if ammo.damageType == 'Explosive' then
        return Rocket.new( ammo.caliber, ammo.itemType, ammo.damageType, capacity, ammo.blastRadius );
    end
    return Magazine.new( ammo.caliber, ammo.itemType, ammo.damageType, capacity );
end

---
-- Creates a random clothing item of the specified category.
-- @param clothingType (string)   The specific clothing part to create.
-- @return             (Clothing) The new clothing instance.
--
function ItemFactory.createClothing( clothingType )
    local rnd = love.math.random( 1, #items.Clothing[clothingType] );
    local template = items.Clothing[clothingType][rnd];
    return Clothing.new( template.name, template.armor, template.itemType, template.clothingType );
end

---
-- Creates a new random bag item.
-- @return (Bag) The new bag instance.
--
function ItemFactory.createBag()
    local rnd = love.math.random( 1, #items.Bag );
    local template = items.Bag[rnd];
    return Bag.new( template.name, template.itemType, template.slots );
end

return ItemFactory;
