local Weapon = require( 'src.items.weapons.Weapon' );

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

            table.insert( items[itemType], template );

            print( string.format( '  %d. %s', i, template.name ));
        end
    end
end

function ItemFactory.loadTemplates()
    print( "Load Weapon Templates:" )
    load( TEMPLATES_DIRECTORY_WEAPONS );
end

function ItemFactory.createWeapon()
    local rnd = love.math.random( 1, #items.Weapon );
    local template = items.Weapon[rnd];
    return Weapon.new( template );
end

return ItemFactory;
