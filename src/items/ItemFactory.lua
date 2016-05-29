local Weapon = require( 'src.items.weapons.Weapon' );
local Clothing = require( 'src.items.Clothing' );

local TEMPLATES_DIRECTORY_FOOTWEAR = 'res/data/items/clothing/footwear/';
local TEMPLATES_DIRECTORY_GLOVES   = 'res/data/items/clothing/gloves/';
local TEMPLATES_DIRECTORY_HEADGEAR = 'res/data/items/clothing/headgear/';
local TEMPLATES_DIRECTORY_JACKETS  = 'res/data/items/clothing/jackets/';
local TEMPLATES_DIRECTORY_SHIRTS   = 'res/data/items/clothing/shirts/';
local TEMPLATES_DIRECTORY_TROUSERS = 'res/data/items/clothing/trousers/';
local TEMPLATES_DIRECTORY_WEAPONS  = 'res/data/items/weapons/';

local ItemFactory = {};

local items = {};

local function load( dir )
    local files = love.filesystem.getDirectoryItems( dir );
    for i, file in ipairs( files ) do
        if love.filesystem.isFile( dir .. file ) then
            local template = love.filesystem.load( dir .. file )();
            local itemType = template.itemType;

            items[itemType] = items[itemType] or {};

            if itemType == 'Clothing' then
                items[itemType][template.clothingType] = items[itemType][template.clothingType] or {};
                table.insert( items[itemType][template.clothingType], template );
            else
                table.insert( items[itemType], template );
            end

            print( string.format( '  %d. %s', i, template.name ));
        end
    end
end

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
end

function ItemFactory.createWeapon()
    local rnd = love.math.random( 1, #items.Weapon );
    local template = items.Weapon[rnd];
    return Weapon.new( template );
end

function ItemFactory.createClothing( clothingType )
    local rnd = love.math.random( 1, #items.Clothing[clothingType] );
    local template = items.Clothing[clothingType][rnd];
    return Clothing.new( template.name, template.itemType, template.clothingType );
end

return ItemFactory;
