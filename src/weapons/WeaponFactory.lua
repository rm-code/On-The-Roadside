local Weapon = require( 'src.weapons.Weapon' );

local WeaponFactory = {};

local weapons = {};

function WeaponFactory.loadTemplates()
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

function WeaponFactory.createWeapon()
    return Weapon.new( weapons[love.math.random( 1, #weapons )] );
end

return WeaponFactory;
