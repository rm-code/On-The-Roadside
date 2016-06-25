local ProjectileManager = {};

-- ------------------------------------------------
-- Private Variables
-- ------------------------------------------------

local queue;

-- ------------------------------------------------
-- Private Functions
-- ------------------------------------------------

---
-- Removes a projectile from the world and hits a tile with the projectile
-- damage.
-- @param index      (number)     The index of the projectile to remove.
-- @param tile       (Tile)       The tile to hit.
-- @param projectile (Projectile) The projectile to remove.
--
local function hitTile( index, tile, projectile )
    queue:removeProjectile( index );
    tile:hit( projectile:getDamage() );
end

-- ------------------------------------------------
-- Public Variables
-- ------------------------------------------------

function ProjectileManager.update( dt, map )
    if not queue then
        return;
    end

    queue:update( dt );

    for i, projectile in pairs( queue:getProjectiles() ) do
        projectile:update( dt );
        local tile = map:getTileAt( projectile:getTilePosition() );
        if projectile:getTile() ~= tile then
            projectile:setTile( tile );

            if not tile then
                print( "Reached map border" );
                queue:removeProjectile( i );
            elseif tile:hasWorldObject() then
                if love.math.random( 0, 100 ) < tile:getWorldObject():getSize() then
                    local energy = projectile:getEnergy();
                    local energyReduction = tile:getWorldObject():isDestructible() and love.math.random( 40, 70 ) or 100;
                    energy = energy - energyReduction;
                    projectile:setEnergy( energy );

                    tile:hit( projectile:getDamage() * ( energyReduction / 100 ));

                    if energy <= 0 then
                        queue:removeProjectile( i );
                    end
                end
            elseif tile == projectile:getTarget() then
                print( "Reached target" );
                hitTile( i, tile, projectile );
            elseif tile:isOccupied() and tile:getCharacter() ~= projectile:getCharacter() then
                print( "Hit character" );
                hitTile( i, tile, projectile );
            end
        end
    end
end

function ProjectileManager.iterate( callback )
    if queue then
        for _, projectile in pairs( queue:getProjectiles() ) do
            callback( projectile:getPosition() );
        end
    end
end

function ProjectileManager.register( nqueue )
    queue = nqueue;
    queue:init();
end

function ProjectileManager.isDone()
    if not queue then
        return true;
    end
    return queue:isDone();
end

return ProjectileManager;
