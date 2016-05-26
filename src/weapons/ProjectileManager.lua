local Projectile = require( 'src.weapons.Projectile' );
local Messenger = require( 'src.Messenger' );
local Queue = require( 'src.Queue' );

local ProjectileManager = {};

function ProjectileManager.new( map )
    local self = {};

    local projectileQueue = Queue.new();
    local projectiles = {};
    local id = 0;
    local timer = 0;

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

    local function spawnProjectile()
        id = id + 1;
        projectiles[id] = projectileQueue:dequeue();
        Messenger.publish( 'SOUND_SHOOT' );
        return projectiles[id];
    end

    function self:update( dt )
        timer = timer - dt;
        if timer < 0 and not projectileQueue.isEmpty() then
            local projectile = spawnProjectile();
            timer = projectileQueue.isEmpty() and 0 or 1 / projectile:getWeapon():getMode();
        end

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

    Messenger.observe( 'ACTION_SHOOT', function( character, origin, target, angle )
        projectileQueue:enqueue( Projectile.new( character, origin, target, angle ));
    end)

    return self;
end

return ProjectileManager;
