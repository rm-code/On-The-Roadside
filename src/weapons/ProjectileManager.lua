local Projectile = require( 'src.weapons.Projectile' );
local Messenger = require( 'src.Messenger' );

local ProjectileManager = {};

function ProjectileManager.new( map )
    local self = {};

    local projectiles = {};
    local id = 0;

    function self:update( dt )
        for i, projectile in pairs( projectiles ) do
            projectile:update( dt );
            local px, py = projectile:getPosition();
            local tile = map:getTileAt( math.floor( px ), math.floor( py ));

            if not tile:isPassable()
                    or tile == projectile:getTarget()
                    or ( tile:isOccupied() and tile:getCharacter() ~= projectile:getCharacter() ) then
                projectiles[i] = nil;
                tile:hit();
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
        projectiles[id] = Projectile.new( character, origin, target );
    end)

    return self;
end

return ProjectileManager;
