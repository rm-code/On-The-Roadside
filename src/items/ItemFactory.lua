local Weapon = require( 'src.items.weapons.Weapon' );
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

local CLOTHING = {
    [ITEM_TYPES.HEADGEAR] = Headgear;
    [ITEM_TYPES.GLOVES]   = Gloves;
    [ITEM_TYPES.JACKET]   = Jacket;
    [ITEM_TYPES.SHIRT]    = Shirt;
    [ITEM_TYPES.TROUSERS] = Trousers;
    [ITEM_TYPES.FOOTWEAR] = Footwear;
}

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

    assert( ammo, 'Ammo type for caliber ' .. caliber .. ' not found!' );

    if ammo.ammoType == 'Rocket' then
        return Rocket.new( ammo.caliber, ammo.itemType, ammo.ammoType, capacity, ammo.blastRadius );
    elseif ammo.ammoType == 'ShotgunShell' then
        return ShotgunShell.new( ammo.caliber, ammo.itemType, ammo.ammoType, capacity, ammo.pellets );
    end
    return Magazine.new( ammo.caliber, ammo.itemType, ammo.ammoType, capacity );
end

---
-- Creates a random clothing item.
-- @param type (string)   The clothing part to create.
-- @return     (Clothing) The new clothing instance.
--
function ItemFactory.createClothing( type )
    local rnd = love.math.random( 1, #items[type] );
    local template = items[type][rnd];
    return CLOTHING[type].new( template.name, template.itemType, template.armor );
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
