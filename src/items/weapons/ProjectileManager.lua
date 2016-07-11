local ProjectileManager = {};

-- ------------------------------------------------
-- Private Variables
-- ------------------------------------------------

local queue;
local map;

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

---
-- Clamps a value to a certain range.
-- @param min (number) The minimum value to clamp to.
-- @param val (number) The value to clamp.
-- @param max (number) The maximum value to clamp to.
-- @return    (number) The clamped value.
--
local function clamp( min, val, max )
    return math.max( min, math.min( val, max ));
end

-- ------------------------------------------------
-- Public Variables
-- ------------------------------------------------

function ProjectileManager.init( nmap )
    map = nmap;
end

function ProjectileManager.update( dt )
    if not queue then
        return;
    end

    queue:update( dt );

    for i, projectile in pairs( queue:getProjectiles() ) do
        -- Moves the projectile.
        projectile:update( dt );

        if projectile:hasReachedTarget() then
            queue:removeProjectile( i );
        end

        if projectile:hasMoved( map ) then
            projectile:updateTile( map );

            local tile = projectile:getTile();
            if not tile then
                print( "Reached map border" );
                queue:removeProjectile( i );
            elseif tile:hasWorldObject() then
                if love.math.random( 0, 100 ) < tile:getWorldObject():getSize() then
                    if not tile:getWorldObject():isDestructible() then
                        hitTile( i, tile, projectile );
                        return;
                    end

                    local energy = projectile:getEnergy();
                    local energyReduction = tile:getWorldObject():getEnergyReduction();
                    energyReduction = love.math.random( energyReduction - 10, energyReduction + 10 );
                    energyReduction = clamp( 1, energyReduction, 100 );

                    energy = energy - energyReduction;
                    projectile:setEnergy( energy );

                    tile:hit( projectile:getDamage() * ( energy / 100 ));

                    if energy <= 0 then
                        queue:removeProjectile( i );
                    end
                end
            elseif tile == projectile:getTarget() then
                print( "Reached target" );
                hitTile( i, tile, projectile );
            elseif tile:isOccupied() then
                print( "Hit character" );
                hitTile( i, tile, projectile );
            end
        end
    end
end

function ProjectileManager.iterate( callback )
    if queue then
        for _, projectile in pairs( queue:getProjectiles() ) do
            callback( projectile:getTile():getPosition() );
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
