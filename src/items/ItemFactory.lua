local Weapon = require( 'src.items.weapons.Weapon' );

local ItemFactory = {};

local weapons = {};

function ItemFactory.loadTemplates()
    local dir = 'res/data/weapons/';

    local files = love.filesystem.getDirectoryItems( dir );
    print("Load Weapon Templates: ");
    for i, file in ipairs( files ) do
        if love.filesystem.isFile( dir .. file ) then
            weapons[#weapons + 1] = love.filesystem.load( dir .. file )();
            print( "  " .. i .. ". " .. file .. " - " .. weapons[#weapons].name );
        end
    end
end

function ItemFactory.createWeapon()
    return Weapon.new( weapons[love.math.random( 1, #weapons )] );
end

return ItemFactory;
