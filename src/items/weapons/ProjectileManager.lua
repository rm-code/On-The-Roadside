local Messenger = require( 'src.Messenger' );
local ExplosionManager = require( 'src.items.weapons.ExplosionManager' );

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
    if projectile:getEffects():isExplosive() then
        ExplosionManager.register( tile, projectile:getEffects():getBlastRadius() );
    else
        tile:hit( projectile:getDamage(), projectile:getDamageType() );
    end
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

        if projectile:hasMoved( map ) then
            projectile:updateTile( map );
            Messenger.publish( 'PROJECTILE_MOVED', projectile );

            local tile = projectile:getTile();
            -- Exit if we reached the map border.
            if not tile then
                queue:removeProjectile( i );
                return;
            end

            -- If the tile contains a world object check if the projectile hits it.
            -- If it hits the world object check for energy reduction.
            if tile:hasWorldObject() and love.math.random( 0, 100 ) < tile:getWorldObject():getSize() then
                -- Stop the bullet if the object is indestructible.
                if not tile:getWorldObject():isDestructible() then
                    -- HACK: Need proper handling for explosive type weapons.
                    if projectile:getEffects():isExplosive() then
                        hitTile( i, projectile:getPreviousTile(), projectile );
                        return;
                    end
                    hitTile( i, tile, projectile );
                    return;
                end

                -- HACK: Need proper handling for explosive type weapons.
                if projectile:getEffects():isExplosive() then
                    hitTile( i, tile, projectile );
                    return;
                end

                -- Projectiles passing through world objects lose some of their energy.
                local energy = projectile:getEnergy();
                local energyReduction = tile:getWorldObject():getEnergyReduction();
                energyReduction = love.math.random( energyReduction - 10, energyReduction + 10 );
                energyReduction = clamp( 1, energyReduction, 100 );

                energy = energy - energyReduction;
                projectile:setEnergy( energy );

                if energy <= 0 or projectile:hasReachedTarget() then
                    hitTile( i, projectile:getTile(), projectile );
                end

                tile:hit( projectile:getDamage() * ( energy / 100 ), projectile:getDamageType() );
                return;
            end

            if projectile:hasReachedTarget() then
                hitTile( i, projectile:getTile(), projectile );
                return;
            end

            if tile:isOccupied() then
                hitTile( i, tile, projectile );
                return;
            end
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
