local Projectile = require( 'src.weapons.Projectile' );
local Messenger = require( 'src.Messenger' );

local ProjectileManager = {};

function ProjectileManager.new( map )
    local self = {};

    local projectiles = {};
    local id = 0;

    ---
    -- Removes a projectile from the world and hits a tile with the projectile
    -- damage.
    -- @param index      (number)     The index of the projectile to remove.
    -- @param tile       (Tile)       The tile to hit.
    -- @param projectile (Projectile) The projectile to remove.
    --
    local function hitTile( index, tile, projectile )
        projectiles[index] = nil;
        tile:hit( projectile:getDamage() );
    end

    function self:update( dt )
        for i, projectile in pairs( projectiles ) do
            projectile:update( dt );
            local tile = map:getTileAt( projectile:getTilePosition() );

            if not tile:isPassable() then
                print( "Hit impassable tile" );
                hitTile( i, tile, projectile );
            elseif tile == projectile:getTarget() then
                print( "Reached target" );
                hitTile( i, tile, projectile );
            elseif tile:isOccupied() and tile:getCharacter() ~= projectile:getCharacter() then
                print( "Hit character" );
                hitTile( i, tile, projectile );
            end
        end
    end

    function self:iterate( callback )
        for _, projectile in pairs( projectiles ) do
            callback( projectile:getPosition() );
        end
    end

    Messenger.observe( 'ACTION_SHOOT', function( character, origin, target )
        id = id + 1;
        projectiles[id] = Projectile.new( character, character:getWeapon():getDamage(), origin, target );
    end)

    return self;
end

return ProjectileManager;
